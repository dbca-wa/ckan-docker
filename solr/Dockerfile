# Upstream ckan/ckan-solr is rebuilt rarely, so its Ubuntu packages fall behind
# security fixes. Rebuilding this image picks up whatever Ubuntu has published.
FROM ckan/ckan-solr:2.11-solr9.9-spatial

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# The CKAN core loads no optional Solr modules (SOLR_MODULES is unset and its
# solrconfig.xml has no <lib> entries), and spatial uses the JTS jar in
# WEB-INF/lib. Removing the modules and standalone tools drops jars that only
# add vulnerability findings. Setting SOLR_MODULES on this image will fail.
RUN rm -rf /opt/solr/modules/* /opt/solr/cross-dc-manager /opt/solr/prometheus-exporter
USER solr
