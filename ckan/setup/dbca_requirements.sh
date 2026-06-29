#!/bin/sh

## Process management ##
# supervisor runs the CKAN job workers (not shipped by the Debian base). Installed
# here so the worker image and the shared dev site-packages volume both have it.
pip3 install supervisor

## CKAN Core extensions ##

# Archiver
pip3 install -e git+https://github.com/ckan/ckanext-archiver.git@master#egg=ckanext-archiver
pip3 install -r ${SRC_DIR}/ckanext-archiver/requirements.txt

# DCAT
pip3 install -e git+https://github.com/ckan/ckanext-dcat.git@v1.5.1#egg=ckanext-dcat
pip3 install -r ${SRC_DIR}/ckanext-dcat/requirements.txt

# Geoview
pip3 install -e git+https://github.com/ckan/ckanext-geoview.git@v0.1.0#egg=ckanext-geoview

# Hierarchy
pip3 install -e git+https://github.com/ckan/ckanext-hierarchy.git@v1.2.2#egg=ckanext-hierarchy
pip3 install -r ${SRC_DIR}/ckanext-hierarchy/requirements.txt

# Pages
pip3 install -e git+https://github.com/ckan/ckanext-pages.git@v0.5.2#egg=ckanext-pages

# PDF View
pip3 install -e git+https://github.com/ckan/ckanext-pdfview.git@0.0.8#egg=ckanext-pdfview

# Report
pip3 install -e git+https://github.com/ckan/ckanext-report.git@master#egg=ckanext-report --exists-action i
pip3 install -r ${SRC_DIR}/ckanext-report/requirements.txt

# Scheming
pip3 install -e git+https://github.com/ckan/ckanext-scheming.git@release-3.0.0#egg=ckanext-scheming

# Showcase
pip3 install -e git+https://github.com/ckan/ckanext-showcase.git@v1.8.3#egg=ckanext-showcase
pip3 install -r ${SRC_DIR}/ckanext-showcase/requirements.txt

# Spatial
# dependencies
export PROJ_DIR=/usr
apt-get update && apt-get install -y --no-install-recommends \
    libgeos-dev \
    libproj-dev \
    proj-bin
pip3 install -e git+https://github.com/ckan/ckanext-spatial.git@master#egg=ckanext-spatial
# pyproj 3.6.1 in ckanext-spatial requirements.txt is not working: download the
# v2.3.0 requirements (which also pin Shapely/geojson/OWSLib) and strip that
# pyproj line so we can install a later compatible pyproj below. Use wget (the
# Debian base does not ship curl).
wget -qO- https://raw.githubusercontent.com/ckan/ckanext-spatial/v2.3.0/requirements.txt \
    | sed 's/pyproj==3.6.1; python_version >= '\''3.9'\''//g' > ${SRC_DIR}/ckanext-spatial/requirements.txt
# manually install a later compatible version of pyproj
pip3 install pyproj==3.7.*
pip3 install -r ${SRC_DIR}/ckanext-spatial/requirements.txt

# XLoader
pip3 install -e git+https://github.com/ckan/ckanext-xloader.git@1.0.1#egg=ckanext-xloader
pip3 install -r ${SRC_DIR}/ckanext-xloader/requirements.txt


## 3rd Party ##
# DOI
# pip3 install -e git+https://github.com/NaturalHistoryMuseum/ckanext-doi@v3.1.10#egg=ckanext-doi

# Office Docs
pip3 install -e git+https://github.com/jqnatividad/ckanext-officedocs.git@master#egg=ckanext-officedocs

# SAML2
# pysaml2 shells out to the xmlsec1 binary for XML signing
apt-get update && apt-get install -y --no-install-recommends xmlsec1
pip3 install -e git+https://github.com/keitaroinc/ckanext-saml2auth.git@v1.3.0#egg=ckanext-saml2auth

## DBCA Project ##

# DBCA
pip3 install -e git+https://github.com/dbca-wa/ckanext-dbca.git@develop#egg=ckanext-dbca

# DOI
pip3 install -e git+https://github.com/dbca-wa/ckanext-doi@develop#egg=ckanext-doi

# QA
# Install qsv dependency for extension ckanext-qa
# file (libmagic) is required by ckanext-qa; unzip is needed to extract the qsv binary
apt-get update && apt-get install -y --no-install-recommends file unzip
# Use the glibc (gnu) qsv build for Debian; the musl build only runs on Alpine
wget -O /tmp/qsv.zip https://github.com/jqnatividad/qsv/releases/download/0.110.0/qsv-0.110.0-x86_64-unknown-linux-gnu.zip
unzip /tmp/qsv.zip -d /usr/local/bin
rm /tmp/qsv.zip
pip3 install -e git+https://github.com/dbca-wa/ckanext-qa.git@develop#egg=ckanext-qa
pip3 install -r ${SRC_DIR}/ckanext-qa/requirements.txt
