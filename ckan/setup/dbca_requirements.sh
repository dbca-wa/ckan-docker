#!/bin/sh

## Process management ##
# supervisor runs the CKAN job workers (not shipped by the Debian base). Installed
# here so the worker image and the shared dev site-packages volume both have it.
pip3 install supervisor

## CKAN Core extensions ##

# Archiver
pip3 install -e git+https://github.com/ckan/ckanext-archiver.git@986f25d91013a9bfdbc55b60ec55a1676e8eeab3#egg=ckanext-archiver
pip3 install -r ${SRC_DIR}/ckanext-archiver/requirements.txt

# DCAT
pip3 install -e git+https://github.com/ckan/ckanext-dcat.git@62e64d596fd051e3902c412b770a5ec3500dc967#egg=ckanext-dcat
pip3 install -r ${SRC_DIR}/ckanext-dcat/requirements.txt

# Geoview
pip3 install -e git+https://github.com/ckan/ckanext-geoview.git@665f54a2ee0667a043b32f35c59eea49d9af9c30#egg=ckanext-geoview

# Hierarchy
pip3 install -e git+https://github.com/ckan/ckanext-hierarchy.git@5428e927995e29ddd7cfa130dc9670d4c4889f19#egg=ckanext-hierarchy
pip3 install -r ${SRC_DIR}/ckanext-hierarchy/requirements.txt

# Pages
pip3 install -e git+https://github.com/ckan/ckanext-pages.git@28eba99ad85d3b9037f5aaddad1f083300c69041#egg=ckanext-pages

# PDF View
pip3 install -e git+https://github.com/ckan/ckanext-pdfview.git@071571546b99498f543ea0c34de44da3b9ac9d7b#egg=ckanext-pdfview

# Report
pip3 install -e git+https://github.com/ckan/ckanext-report.git@5f25ae4e93597933520b6a76e8dbad9f5195f897#egg=ckanext-report --exists-action i
pip3 install -r ${SRC_DIR}/ckanext-report/requirements.txt

# Scheming
pip3 install -e git+https://github.com/ckan/ckanext-scheming.git@release-3.1.0#egg=ckanext-scheming

# Showcase
pip3 install -e git+https://github.com/ckan/ckanext-showcase.git@v1.8.4#egg=ckanext-showcase
pip3 install -r ${SRC_DIR}/ckanext-showcase/requirements.txt

# Spatial
# dependencies
export PROJ_DIR=/usr
apt-get update && apt-get install -y --no-install-recommends \
    libgeos-dev \
    libproj-dev \
    proj-bin
pip3 install -e git+https://github.com/ckan/ckanext-spatial.git@460d7053cf60c1c2b30a953c60f5baf8f5ac821f#egg=ckanext-spatial

pip3 install -r ${SRC_DIR}/ckanext-spatial/requirements.txt

# XLoader
pip3 install -e git+https://github.com/ckan/ckanext-xloader.git@2.3.1#egg=ckanext-xloader
pip3 install -r ${SRC_DIR}/ckanext-xloader/requirements.txt


## 3rd Party ##
# DOI
# pip3 install -e git+https://github.com/NaturalHistoryMuseum/ckanext-doi@v3.1.10#egg=ckanext-doi

# Office Docs
pip3 install -e git+https://github.com/jqnatividad/ckanext-officedocs.git@b936b89b6f2c81c347f4a6cd7e6fa0762db53b33#egg=ckanext-officedocs

# SAML2
# pysaml2 shells out to the xmlsec1 binary for XML signing
apt-get update && apt-get install -y --no-install-recommends xmlsec1
pip3 install -e git+https://github.com/keitaroinc/ckanext-saml2auth.git@53180596388ed458cd7a03c422568135c40fc7fd#egg=ckanext-saml2auth

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
