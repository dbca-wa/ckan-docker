#!/bin/sh

## CKAN Core extensions ##

# Archiver
pip3 install -e git+https://github.com/ckan/ckanext-archiver.git@master#egg=ckanext-archiver
pip3 install -r ${SRC_DIR}/ckanext-archiver/requirements.txt

# DCAT
pip3 install -e git+https://github.com/ckan/ckanext-dcat.git@v1.5.1#egg=ckanext-dcat
pip3 install -r ${SRC_DIR}/ckanext-dcat/requirements.txt

# Hierarchy
pip3 install -e git+https://github.com/ckan/ckanext-hierarchy.git@v1.2.1#egg=ckanext-hierarchy
pip3 install -r ${SRC_DIR}/ckanext-hierarchy/requirements.txt

# Pages
pip3 install -e git+https://github.com/ckan/ckanext-pages.git@v0.5.2#egg=ckanext-pages

# PDF View
pip3 install -e git+https://github.com/ckan/ckanext-pdfview.git@0.0.8#egg=ckanext-pdfview

# Report
pip3 install -e git+http://github.com/ckan/ckanext-report.git@master#egg=ckanext-report --exists-action i
pip3 install -r ${SRC_DIR}/ckanext-report/requirements.txt

# # Showcase
pip3 install -e git+https://github.com/ckan/ckanext-showcase.git@v1.7.0#egg=ckanext-showcase
pip3 install -r ${SRC_DIR}/ckanext-showcase/requirements.txt

# Scheming
pip3 install -e git+https://github.com/ckan/ckanext-scheming.git@release-3.0.0#egg=ckanext-scheming

# Spatial
# dependencies
export PROJ_DIR=/usr
apk add --no-cache \
    geos \
    geos-dev \
    proj-util \
    proj-dev 
pip3 install -e git+https://github.com/ckan/ckanext-spatial.git@master#egg=ckanext-spatial
# Incompatibility with Shapely >2 Due to NumPy 2.0 Update https://github.com/ckan/ckanext-spatial/issues/330
pip3 install "numpy>=1.26,<2"
pip3 install -r ${SRC_DIR}/ckanext-spatial/requirements.txt

# XLoader
pip3 install -e git+https://github.com/ckan/ckanext-xloader.git@1.0.1#egg=ckanext-xloader
pip3 install -r ${SRC_DIR}/ckanext-xloader/requirements.txt

# Geoview
pip3 install -e git+https://github.com/ckan/ckanext-geoview.git@v0.1.0#egg=ckanext-geoview


## 3rd Party ##
# DOI
# pip3 install -e git+https://github.com/NaturalHistoryMuseum/ckanext-doi@v3.1.10#egg=ckanext-doi

# Office Docs
pip3 install -e git+https://github.com/jqnatividad/ckanext-officedocs.git@master#egg=ckanext-officedocs

# SAML2
pip3 install -e git+https://github.com/keitaroinc/ckanext-saml2auth.git@v1.3.0#egg=ckanext-saml2auth

## DBCA Project ##

# DBCA
pip3 install -e git+https://github.com/dbca-wa/ckanext-dbca.git@main#egg=ckanext-dbca

# DOI
pip3 install -e git+https://github.com/dbca-wa/ckanext-doi@main#egg=ckanext-doi

# QA
# Install qsv dependency for extension ckanext-qa
wget -O /tmp/qsv.zip https://github.com/jqnatividad/qsv/releases/download/0.110.0/qsv-0.110.0-x86_64-unknown-linux-musl.zip
unzip /tmp/qsv.zip -d /usr/local/bin
rm /tmp/qsv.zip
apk add file
pip3 install -e git+https://github.com/dbca-wa/ckanext-qa.git@master#egg=ckanext-qa
pip3 install -r ${SRC_DIR}/ckanext-qa/requirements.txt
