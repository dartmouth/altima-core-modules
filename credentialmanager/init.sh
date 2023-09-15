alias ${primary_credential_alias}='get_cred | clip'

function get_cred
{
  get_cred_${datastore} "$@"
}

function set_cred
{
  set_cred_${datastore} "$@"
}

gen ()
{
  local COUNT=${1:-1};
  local LENGTH=${2:-32};
  local LC_CTYPE=C
  local LANG=C
  for i in `seq 1 $COUNT`;
  do
      cat /dev/urandom | tr -dc '_a-zA-Z0-9' | fold -w $LENGTH | head -n 1;
  done
}

function get_cred_keychain
{
  local CRED_PATH=${1:-"${primary_credential_path}"}
  /usr/bin/security find-generic-password -a "$CRED_PATH" -s "$CRED_PATH" -w | tr -d '\n'
}

function set_cred_keychain
{
  local CRED_PATH="$1"
  local PASSWORD="$2"
  /usr/bin/security add-generic-password -a "$CRED_PATH" -s "$CRED_PATH" -U -w "$PASSWORD"
}

function get_cred_pass
{
  local CRED_PATH=${1:-"${primary_credential_path}"}
  echo -n "$(pass ""$CRED_PATH"")"
}

function set_cred_pass
{
  local CRED_PATH="$1"
  local PASSWORD="$2"
  echo -n "$PASSWORD" | pass insert --force --echo "$CRED_PATH"
}