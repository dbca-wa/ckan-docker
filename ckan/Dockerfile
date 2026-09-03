FROM ckan/ckan-base:2.11.6

# CKAN 2.11 Debian base uses a two-user model (ckan-sys owns /usr/local + the app
# dir; ckan runs the process). Install as root, drop back to ckan at the end.
USER root

# --- PATCH SECTION START ---
# Debian security updates on top of the pinned base, minus the kernel headers it
# installs (a container never uses them).
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    apt-get purge -y 'linux-headers-*' 'linux-kbuild-*' 'linux-compiler-gcc-*' && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# --- PATCH SECTION END ---

# ===== DBCA: install extensions (expensive layer; changes rarely vs config) =====
# dbca_requirements.sh handles its own apt/pip deps, incl. xmlsec1 for saml2auth.
# ckanext-dbca is pinned to a SHA in dbca_requirements.sh, like every other
# extension; nothing to override here.
COPY setup/dbca_requirements.sh setup/dbca_requirements.txt ${APP_DIR}
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

# --- RUNTIME SLIM START ---
# Drop build-only toolchain, -dev packages (from the base and dbca_requirements.sh)
# and pip. Keeps runtime libs the extensions need, wget (compose healthcheck), patch (step below).
# Production only: Dockerfile.dev keeps the toolchain for runtime pip installs.
RUN keep="libpq5 file libmagic1 libgeos-c1v5 libproj25 xmlsec1 wget patch"; \
    for p in $keep; do dpkg -s "$p" >/dev/null 2>&1 && apt-mark manual "$p"; done; \
    drop=""; for p in git unzip g++ gcc cpp binutils libtool libpq-dev libgeos-dev libproj-dev proj-bin libc6-dev linux-libc-dev libssl-dev; do \
        dpkg -s "$p" >/dev/null 2>&1 && drop="$drop $p"; done; \
    DEBIAN_FRONTEND=noninteractive apt-get purge -y $drop && \
    apt-get autoremove -y --purge && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /root/.cache/pip && \
    pip3 uninstall -y pip
# --- RUNTIME SLIM END ---

USER ckan

RUN for d in $APP_DIR/patches/*; do \
        if [ -d $d ]; then \
            for f in `ls $d/*.patch | sort -g`; do \
                cd $SRC_DIR/`basename "$d"` && echo "$0: Applying patch $f to $SRC_DIR/`basename $d`"; patch -p1 < "$f" ; \
            done ; \
        fi ; \
    done
