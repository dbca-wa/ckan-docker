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
        if [ -n "$CKANEXT__XLOADER__API_TOKEN" ]; then
            echo "Using ckanext.xloader.api_token from CKANEXT__XLOADER__API_TOKEN"
        else
            CKAN_INI=$APP_DIR/ckan.ini
            # Use the CKAN_SYSADMIN_NAME or CKAN_SITE_ID to create a token for the xloader user
            export CKAN_SITE_ID=$(grep '^ckan\.site_id ' $CKAN_INI | cut -d'=' -f2)
            USER=${CKAN_SYSADMIN_NAME:-$CKAN_SITE_ID}
            if ckan -c $APP_DIR/config/dbca.ini user show "$USER" | tr -d '[:space:]' | grep -q "User:None"; then
                if [ -z "$CKAN_SYSADMIN_PASSWORD" ] || [ -z "$CKAN_SYSADMIN_EMAIL" ]; then
                    echo "Cannot create missing xloader token user $USER: CKAN_SYSADMIN_PASSWORD or CKAN_SYSADMIN_EMAIL is not set"
                    exit 1
                fi
                echo "Creating missing xloader token user $USER"
                ckan -c $APP_DIR/config/dbca.ini user add "$USER" "password=$CKAN_SYSADMIN_PASSWORD" "email=$CKAN_SYSADMIN_EMAIL"
                ckan -c $APP_DIR/config/dbca.ini sysadmin add "$USER"
            fi
            # Add ckan.xloader.api_token to the CKAN config file
            echo "Setting ckanext.xloader.api_token for user $USER"
            XLOADER_API_TOKEN=$(ckan -c $APP_DIR/config/dbca.ini user token add "$USER" xloader | tail -n 1 | tr -d '\t')
            if [ -z "$XLOADER_API_TOKEN" ]; then
                echo "Failed to generate ckanext.xloader.api_token for user $USER"
                exit 1
            fi
            ckan config-tool $CKAN_INI "ckanext.xloader.api_token=$XLOADER_API_TOKEN"
        fi
    fi
    CKAN_INI=$APP_DIR/config/dbca.ini 

    # activity is a bundled plugin in CKAN 2.11 with its own migration branch
    # (adds activity.permission_labels); core db init does not apply it.
    if [[ $CKAN__PLUGINS == *"activity"* ]]; then
        ckan -c $CKAN_INI db upgrade -p activity
    fi

    # CKAN 2.11 changed the datastore data-dictionary field storage; migrate
    # existing datastore tables (no-op on a fresh datastore).
    if [[ $CKAN__PLUGINS == *"datastore"* ]]; then
        ckan -c $CKAN_INI datastore upgrade
    fi

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
        ckan -c $CKAN_INI db upgrade -p pages
    fi

    if [[ $CKAN__PLUGINS == *"showcase"* ]]; then
        ckan -c $CKAN_INI db upgrade -p showcase
    fi

    # doi 4.0.4 dropped `doi initdb` (bound-metadata) for an alembic migration.
    if [[ $CKAN__PLUGINS == *"doi"* ]]; then
        ckan -c $CKAN_INI db upgrade -p doi
    fi

    if [[ $CKAN__PLUGINS == *"dbca"* ]]; then
        ckan -c $CKAN_INI db upgrade -p dbca
        ckan -c $CKAN_INI dbca load_spatial_data
    fi

    # Set the container as ready so the startup scripts are not run again
    touch /tmp/container_ready
fi
