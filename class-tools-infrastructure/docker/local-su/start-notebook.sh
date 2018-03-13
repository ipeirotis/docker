#!/bin/bash

set -e

# overwrite permission changes when mounting persistent volumes
sudo chmod -R 777 /home

python3 -u /clone_nbs.py

#disable forrmgrader
sudo jupyter nbextension disable --sys-prefix formgrader/main --section=tree
sudo jupyter serverextension disable --sys-prefix nbgrader.server_extensions.formgrader

if [[ ! -z "${MYSQL_HOST}" ]]; then
    if sudo service mysql status; then
        sudo service mysql stop
    fi
else
    sudo -E chown -R mysql:mysql ${MYSQL_DATA_DIR} ${MYSQL_RUN_DIR}; sudo service mysql start
fi

exec jupyter notebook --no-browser --allow-root $*
