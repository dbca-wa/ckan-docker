FROM ckan/ckan-base:2.11

# CKAN 2.11 Debian base uses a two-user model (ckan-sys owns /usr/local + the app
# dir; ckan runs the process). Install as root, drop back to ckan at the end.
USER root

# Install DBCA extensions (handles its own apt/pip deps, incl. xmlsec1 for saml2auth)
COPY setup/dbca_requirements.sh ${APP_DIR}
RUN chmod +x ${APP_DIR}/dbca_requirements.sh && \
    ${APP_DIR}/dbca_requirements.sh

# DBCA SAML metadata
COPY saml ${APP_DIR}/saml

# Override the default start_ckan.sh script with the DBCA version
COPY setup/dbca_start_ckan.sh.override ${APP_DIR}/start_ckan.sh
RUN chmod +x ${APP_DIR}/start_ckan.sh

# DBCA config files; use dbca.ini as the active CKAN config
COPY config/*.ini ${APP_DIR}/config/
ENV CKAN_INI=${APP_DIR}/config/dbca.ini

# Copy custom initialization scripts
COPY --chown=ckan-sys:ckan-sys docker-entrypoint.d/* /docker-entrypoint.d/

# Apply any patches needed to CKAN core or any of the built extensions (not the
# runtime mounted ones)
COPY --chown=ckan-sys:ckan-sys patches ${APP_DIR}/patches

# Re-assert ownership after the root install steps
RUN chown -R ckan:ckan-sys $APP_DIR && \
    chown -R ckan:ckan-sys /usr/local/lib/python3.10/site-packages/

USER ckan

RUN for d in $APP_DIR/patches/*; do \
        if [ -d $d ]; then \
            for f in `ls $d/*.patch | sort -g`; do \
                cd $SRC_DIR/`basename "$d"` && echo "$0: Applying patch $f to $SRC_DIR/`basename $d`"; patch -p1 < "$f" ; \
            done ; \
        fi ; \
    done
