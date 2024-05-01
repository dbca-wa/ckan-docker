#!/bin/bash

# Only run these start up scripts the first time the container is created
if [ ! -f /tmp/container_ready ]; then
    ## Create logs folder/files and set permissions
    mkdir -p $APP_DIR/logs
    touch $APP_DIR/logs/ckan.log
    touch $APP_DIR/logs/ckan-worker.log
    chown -R ckan:ckan $APP_DIR/logs

    ## Create archive folder and set permissions
    mkdir -p $CKAN_STORAGE_PATH/archiver
    chown -R ckan:ckan $CKAN_STORAGE_PATH/archiver

    export CKAN__PLUGINS=$(grep '^ckan\.plugins' $APP_DIR/config/dbca.ini | cut -d'=' -f2)
    echo "CKAN__PLUGINS: $CKAN__PLUGINS"

    if [[ $CKAN__PLUGINS == *"xloader"* ]]; then
        CKAN_INI=$APP_DIR/ckan.ini
        # Add ckan.xloader.api_token to the CKAN config file (updated with corrected value later)
        echo "Setting a temporary value for ckanext.xloader.api_token"
        ckan config-tool $CKAN_INI "ckanext.xloader.api_token=$(ckan -c $APP_DIR/config/dbca.ini user token add $CKAN_SYSADMIN_NAME xloader | tail -n 1 | tr -d '\t')"
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

    if [[ $CKAN__PLUGINS == *"dbca"* ]]; then
        ckan -c $CKAN_INI db upgrade -p dbca
        ckan -c $CKAN_INI dbca load_spatial_data
    fi

    # if [[ $CKAN__PLUGINS == *"harvest"* ]]; then
    #     ckan -c $CKAN_INI db upgrade -p harvest
    # fi

    # Set the container as ready so the startup scripts are not run again
    touch /tmp/container_ready
fi
