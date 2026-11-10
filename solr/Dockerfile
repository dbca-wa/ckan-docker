# Upstream ckan/ckan-solr is rebuilt rarely, so its Ubuntu packages fall behind
# security fixes. Rebuilding this image picks up whatever Ubuntu has published.
FROM ckan/ckan-solr:2.11-solr9.9-spatial

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
USER solr
