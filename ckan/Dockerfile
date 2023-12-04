FROM ckan/ckan-base:2.10.1

# Install qsv dependency for extension ckanext-qa
RUN wget https://github.com/jqnatividad/qsv/releases/download/0.110.0/qsv-0.110.0-x86_64-unknown-linux-musl.zip && \
    unzip qsv-0.110.0-x86_64-unknown-linux-musl.zip -d /tmp/qsv && \
    rm qsv-0.110.0-x86_64-unknown-linux-musl.zip  && \
    mv /tmp/qsv/qsv /usr/local/bin && \
    rm -rf /tmp/qsv

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
