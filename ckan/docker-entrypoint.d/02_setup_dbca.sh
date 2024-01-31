#!/bin/bash

echo "CKAN__PLUGINS: $CKAN__PLUGINS"

if [[ $CKAN__PLUGINS == *"xloader"* ]]; then
    CKAN_INI=$APP_DIR/ckan.ini
    # Add ckan.xloader.api_token to the CKAN config file (updated with corrected value later)
    echo "Setting a temporary value for ckanext.xloader.api_token"
    ckan config-tool $CKAN_INI "ckanext.xloader.api_token=$(ckan -c $CKAN_INI user token add $CKAN_SYSADMIN_NAME xloader | tail -n 1 | tr -d '\t')"
fi
CKAN_INI=$APP_DIR/config/dbca.ini 

if [[ $CKAN__PLUGINS == *"archiver"* ]]; then
    ckan -c $CKAN_INI archiver init
fi

if [[ $CKAN__PLUGINS == *"report"* ]]; then
    ckan -c $CKAN_INI report initdb
fi

if [[ $CKAN__PLUGINS == *"qa"* ]]; then
    ckan -c $CKAN_INI qa init
fi

if [[ $CKAN__PLUGINS == *"pages"* ]]; then
    ckan -c $CKAN_INI pages initdb
fi

if [[ $CKAN__PLUGINS == *"doi"* ]]; then
    ckan -c $CKAN_INI doi initdb
fi

# if [[ $CKAN__PLUGINS == *"harvest"* ]]; then
#     ckan -c $CKAN_INI db upgrade -p harvest
# fi