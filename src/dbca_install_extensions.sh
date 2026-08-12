
#!/bin/sh

### Extensions that need upgrading to be compatiable with CKAN 2.10 ###
# Uncomment the following lines to install these extension you are working on to upgrade to CKAN 2.10

cd src/
# DBCA
git clone https://github.com/dbca-wa/ckanext-dbca.git
# QA
git clone https://github.com/dbca-wa/ckanext-qa.git
#These extensions will be installed by default, but we don't want them
sed -i".$(date +%Y%m%d_%H%M%S).bak" -e '/ckanext-report/d' -e '/ckanext-archiver/d' ckanext-qa/dev-requirements.txt
# DOI
git clone https://github.com/dbca-wa/ckanext-doi

echo "Ready to build project: ahoy build"
