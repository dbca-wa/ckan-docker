#!/bin/bash

# Only run these start up scripts the first time the container is created
if [ ! -f /tmp/container_ready ]; then
    CKAN_INI=$APP_DIR/config/dbca.ini 
    export CKAN__PLUGINS=$(grep '^ckan\.plugins' $APP_DIR/config/dbca.ini | cut -d'=' -f2)
    echo "CKAN__PLUGINS: $CKAN__PLUGINS"

    ## Create logs folder/file
    mkdir -p $APP_DIR/logs
    touch $APP_DIR/logs/ckan-worker.log
    touch $APP_DIR/logs/supervisord.log

    ## Create webassets folder
    mkdir -p $APP_DIR/webassets
    ckan -c $CKAN_INI asset build

    ## Create archive folder
    mkdir -p $CKAN_STORAGE_PATH/archiver

    ## Create resources folder
    mkdir -p $CKAN_STORAGE_PATH/resources

    if [[ $CKAN__PLUGINS == *"xloader"* ]]; then
        CKAN_INI=$APP_DIR/ckan.ini
        # Use the CKAN_SYSADMIN_NAME or CKAN_SITE_ID to create a token for the xloader user
        export CKAN_SITE_ID=$(grep '^ckan\.site_id ' $CKAN_INI | cut -d'=' -f2)
        USER=${CKAN_SYSADMIN_NAME:-$CKAN_SITE_ID}
        # Add ckan.xloader.api_token to the CKAN config file (updated with corrected value later)
        echo "Setting a temporary value for user $USER for ckanext.xloader.api_token"
        ckan config-tool $CKAN_INI "ckanext.xloader.api_token=$(ckan -c $APP_DIR/config/dbca.ini user token add $USER xloader | tail -n 1 | tr -d '\t')"
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

    if [[ $CKAN__PLUGINS == *"showcase"* ]]; then
        ckan -c $CKAN_INI db upgrade -p showcase
    fi

    if [[ $CKAN__PLUGINS == *"doi"* ]]; then
        ckan -c $CKAN_INI doi initdb
    fi

    if [[ $CKAN__PLUGINS == *"dbca"* ]]; then
        ckan -c $CKAN_INI db upgrade -p dbca
        ckan -c $CKAN_INI dbca load_spatial_data
    fi

    # Set the container as ready so the startup scripts are not run again
    touch /tmp/container_ready
fi
