# altima-core-modules

## Special Environment Variables

`${module_dir}` - Full path to the current module's install directory
`${module_name}` - Name of the current module (also the module directory name)
`${altima_config_path}` - Full path to altima configation file (ex. `~/.config/altima/altima.toml`)


## Release updated modules

* Create tarballs for each module
    ```shell
    VERSION=v0.0.1
    for MODULE in $(ls -d */ | sed 's/\///' | grep -v releases )
    do 
      echo "Processing $MODULE"
      (cd $MODULE; tar -czf ../releases/${MODULE}-${VERSION}.tgz .)
    done
    ```
* Update `index.yaml` with new releases
* Add/Commit/Tag/Push Update
    ```shell
    git add -A
    git commit -m "Release: $VERSION"
    git tag $VERSION
    git push
    git push --tags
    ```
