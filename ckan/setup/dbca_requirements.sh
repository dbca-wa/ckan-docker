#!/bin/sh

# Latest pip before installing anything below
pip3 install -U pip

## Process management ##
# supervisor runs the CKAN job workers (not shipped by the Debian base). Installed
# here so the worker image and the shared dev site-packages volume both have it.
pip3 install supervisor

## CKAN Core extensions ##

# Archiver
pip3 install -e git+https://github.com/ckan/ckanext-archiver.git@3876e19beaf17eb7492bb228b2657498339b4849#egg=ckanext-archiver
pip3 install -r ${SRC_DIR}/ckanext-archiver/requirements.txt

# DCAT
pip3 install -e git+https://github.com/ckan/ckanext-dcat.git@v2.4.4#egg=ckanext-dcat
pip3 install -r ${SRC_DIR}/ckanext-dcat/requirements.txt

# Geoview
pip3 install -e git+https://github.com/ckan/ckanext-geoview.git@665f54a2ee0667a043b32f35c59eea49d9af9c30#egg=ckanext-geoview

# Hierarchy
pip3 install -e git+https://github.com/ckan/ckanext-hierarchy.git@53c1ee74805d79aef7c9c01cc513eb881cb8928f#egg=ckanext-hierarchy
pip3 install -r ${SRC_DIR}/ckanext-hierarchy/requirements.txt

# Pages
pip3 install -e git+https://github.com/ckan/ckanext-pages.git@28eba99ad85d3b9037f5aaddad1f083300c69041#egg=ckanext-pages

# PDF View
pip3 install -e git+https://github.com/ckan/ckanext-pdfview.git@071571546b99498f543ea0c34de44da3b9ac9d7b#egg=ckanext-pdfview

# QA
# Install qsv dependency for extension ckanext-qa
# file (libmagic) is required by ckanext-qa; unzip is needed to extract the qsv binary
apt-get update && apt-get install -y --no-install-recommends file unzip
# Use the musl (static) qsv build: the gnu build needs glibc 2.38+, newer than
# Debian 12 bookworm's 2.36, but musl runs fine here since it's statically linked.
# Pinned to match the version ckanext-qa's own upstream CI tests against; the
# project moved from jqnatividad/qsv to dathere/qsv and rebased its versioning.
wget -O /tmp/qsv.zip https://github.com/dathere/qsv/releases/download/21.1.0/qsv-21.1.0-x86_64-unknown-linux-musl.zip
unzip /tmp/qsv.zip -d /usr/local/bin
rm /tmp/qsv.zip
pip3 install -e git+https://github.com/ckan/ckanext-qa.git@a54141a4aa3056bc3c6bf597665c28a9f31e04a1#egg=ckanext-qa
pip3 install -r ${SRC_DIR}/ckanext-qa/requirements.txt

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
pip3 install -e git+https://github.com/ckan/ckanext-spatial.git@v2.3.2#egg=ckanext-spatial

pip3 install -r ${SRC_DIR}/ckanext-spatial/requirements.txt

# XLoader
pip3 install -e git+https://github.com/ckan/ckanext-xloader.git@2.4.0#egg=ckanext-xloader
pip3 install -r ${SRC_DIR}/ckanext-xloader/requirements.txt


## 3rd Party ##
# DOI
pip3 install -e git+https://github.com/NaturalHistoryMuseum/ckanext-doi.git@v4.0.4#egg=ckanext-doi

# Office Docs
pip3 install -e git+https://github.com/jqnatividad/ckanext-officedocs.git@b936b89b6f2c81c347f4a6cd7e6fa0762db53b33#egg=ckanext-officedocs

# SAML2
# pysaml2 shells out to the xmlsec1 binary for XML signing
apt-get update && apt-get install -y --no-install-recommends xmlsec1
pip3 install -e git+https://github.com/salsadigitalauorg/ckanext-saml2auth.git@salsa-1.4.0#egg=ckanext-saml2auth

## DBCA Project ##

# DBCA
# Ref is build-time configurable so releases can pin an immutable tag/SHA instead
# of a moving branch. Defaults to develop for local/dev builds; CI sets it per branch.
pip3 install -e git+https://github.com/dbca-wa/ckanext-dbca.git@${CKANEXT_DBCA_REF:-develop}#egg=ckanext-dbca

## Project-level pins (see dbca_requirements.txt) ##
pip3 install -r "$(dirname "$0")/dbca_requirements.txt"
