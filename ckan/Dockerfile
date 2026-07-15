FROM ckan/ckan-base:2.11

# CKAN 2.11 Debian base uses a two-user model (ckan-sys owns /usr/local + the app
# dir; ckan runs the process). Install as root, drop back to ckan at the end.
USER root

# ===== DBCA: install extensions (expensive layer; changes rarely vs config) =====
# dbca_requirements.sh handles its own apt/pip deps, incl. xmlsec1 for saml2auth.
# CKANEXT_DBCA_REF pins the ckanext-dbca git ref; CI passes a tag/SHA for releases
# so master builds don't track a moving branch (defaults to develop for local builds).
ARG CKANEXT_DBCA_REF=develop
ENV CKANEXT_DBCA_REF=${CKANEXT_DBCA_REF}
COPY setup/dbca_requirements.sh ${APP_DIR}
RUN chmod +x ${APP_DIR}/dbca_requirements.sh && \
    ${APP_DIR}/dbca_requirements.sh
# chown site-packages next to the install so it caches with it, rather than being
# re-run every time the app files / config below change.
RUN chown -R ckan:ckan-sys /usr/local/lib/python3.10/site-packages/

# ===== DBCA: app files (cheap layers; change often) =====
# SAML IdP metadata
COPY saml ${APP_DIR}/saml
# Override the default start_ckan.sh with the DBCA version
COPY setup/dbca_start_ckan.sh.override ${APP_DIR}/start_ckan.sh
RUN chmod +x ${APP_DIR}/start_ckan.sh
# DBCA config files; use dbca.ini as the active CKAN config
COPY config/*.ini ${APP_DIR}/config/
ENV CKAN_INI=${APP_DIR}/config/dbca.ini

# ===== Upstream: init scripts + patches =====
COPY --chown=ckan-sys:ckan-sys docker-entrypoint.d/* /docker-entrypoint.d/
# Patches for CKAN core or the built extensions (not the runtime-mounted ones)
COPY --chown=ckan-sys:ckan-sys patches ${APP_DIR}/patches

# Re-assert app-dir ownership after the root COPY steps (cheap; site-packages
# was already chowned above)
RUN chown -R ckan:ckan-sys $APP_DIR

USER ckan

RUN for d in $APP_DIR/patches/*; do \
        if [ -d $d ]; then \
            for f in `ls $d/*.patch | sort -g`; do \
                cd $SRC_DIR/`basename "$d"` && echo "$0: Applying patch $f to $SRC_DIR/`basename $d`"; patch -p1 < "$f" ; \
            done ; \
        fi ; \
    done
