function get_cyberark_api_token
{
  if [ -z $1 ]; then
    echo -n "Username: "; read USER_NAME
  else
    local USER_NAME="$1"
  fi
  if [ -z $2 ]; then
    echo -n "Password: "; stty -echo; read PASSWORD; stty echo; echo
  else
    local PASSWORD="$2"
  fi

  curl --request POST \
    --url "${base_url}/PasswordVault/WebServices/auth/Cyberark/CyberArkAuthenticationService.svc/Logon" \
    --header 'content-type: application/json' \
    --silent \
    --data "{
    \"username\": \"$USER_NAME\",
    \"password\": \"$PASSWORD\",
    \"useRadiusAuthentication\": \"true\",
    \"connectionNumber\": \"1\"
  }" | jq -r '.CyberArkLogonResult'
}

function get_cyberark_account_id
{
  local TOKEN="$1"
  local ACCOUNT="$2"
  local SAFE="$3"
  curl --request GET \
    --url "${base_url}/PasswordVault/WebServices/PIMServices.svc/Accounts?Keywords=$ACCOUNT&Safe=$SAFE" \
    --header "Authorization: $TOKEN" \
    --header 'Content-Type: application/json' \
    --silent \
  | jq -r '.accounts'
  # | jq -r '.accounts[0].AccountID'
}

function get_cyberark_password
{
  local TOKEN="$1"
  local ACCOUNT_ID="$2"
  curl --request GET \
    --url "${base_url}/PasswordVault/WebServices/PIMServices.svc/Accounts/$ACCOUNT_ID/Credentials" \
    --header "Authorization: $TOKEN" \
    --header 'Content-Type: application/json' \
    --silent
}

function ucred
{
  if [ -z "${api_credential_path}" ] || [ "${api_credential_path}" = "null" ]; then
    local API_PASSWORD=""
    echo -n "Password for ${api_credential_username}: "; stty -echo; read PASSWORD; stty echo; echo
  else
    local API_PASSWORD=$(get_cred ${api_credential_path})
  fi
  local TOKEN=$(get_cyberark_api_token "${api_credential_username}" $API_PASSWORD)

  local total_accounts=$(cat ${altima_config_path} | rq -t | jq ".modules.${module_name}.accounts | length")
  for i in $(seq 0 $(($total_accounts-1))); do
    local account_id=$(cat ${altima_config_path} | rq -t | jq -r ".modules.${module_name}.accounts[$i].id")
    local account_path=$(cat ${altima_config_path} | rq -t | jq -r ".modules.${module_name}.accounts[$i].path")
    # echo "i: $i"
    # echo "account_id: $account_id"
    # echo "account_path: $account_path"

    if [[ ${account_id} != 'null' ]] && [[ ${account_path} != 'null' ]]; then
      local PASSWORD=$(get_cyberark_password $TOKEN "${account_id}")
      if [[ "$PASSWORD" = *"Error"* ]]; then
        printf "%24s: ERROR!\n" "${account_path}"
      else
        HIDE_PASSWORD=${PASSWORD:0:2}********
        printf "%24s: %-24s\n" "${account_path}" "$HIDE_PASSWORD"
      fi
      set_cred ${account_path} "$PASSWORD" > /dev/null
    fi
  done
}

function add_cyberark_credential
{
  local TOKEN="$1"
  local BODY="$2"
  curl --request POST \
    --url "${base_url}/passwordvault/api/accounts" \
    --header "Authorization: $TOKEN" \
    --header 'Content-Type: application/json' \
    --data "$BODY"
}

