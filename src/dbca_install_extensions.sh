
#!/bin/sh

### Extensions that need upgrading to be compatiable with CKAN 2.10 ###
# Uncomment the following lines to install these extension you are working on to upgrade to CKAN 2.10

cd src/
# DBCA
git clone https://github.com/dbca-wa/ckanext-dbca.git

echo "Ready to build project: ahoy build"
