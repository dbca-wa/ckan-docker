FROM ckan/ckan-base:2.10.6

# Install any extensions needed by your CKAN instance
# See Dockerfile.dev for more details and examples
COPY setup/dbca_requirements.sh ${APP_DIR}
RUN pip3 install pip --upgrade && \
    chmod +x ${APP_DIR}/dbca_requirements.sh && \
    ${APP_DIR}/dbca_requirements.sh

# Copy custom initialization scripts
COPY docker-entrypoint.d/* /docker-entrypoint.d/

# Apply any patches needed to CKAN core or any of the built extensions (not the
# runtime mounted ones)
COPY patches ${APP_DIR}/patches

RUN for d in $APP_DIR/patches/*; do \
        if [ -d $d ]; then \
            for f in `ls $d/*.patch | sort -g`; do \
                cd $SRC_DIR/`basename "$d"` && echo "$0: Applying patch $f to $SRC_DIR/`basename $d`"; patch -p1 < "$f" ; \
            done ; \
        fi ; \
    done

## DBCA specific configuration ##

# ckanext-saml2auth dependencies
RUN apk add xmlsec-dev
COPY saml ${APP_DIR}/saml

# Override the default start_ckan.sh script
COPY setup/dbca_start_ckan.sh.override ${APP_DIR}/start_ckan.sh
RUN chmod +x ${APP_DIR}/start_ckan.sh

# Copy config files
COPY config/*.ini ${APP_DIR}/config/

# Override default CKAN config file to use dbca.ini
ENV CKAN_INI=${APP_DIR}/config/dbca.ini

# Set the permissions to the ckan user
RUN chown -R ckan:ckan $APP_DIR && \
    chown -R ckan:ckan /usr/lib/python3.10/site-packages/ && \
    chown -R ckan:ckan /usr/bin/

# Set the default user to ckan
USER ckan