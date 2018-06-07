#!/bin/bash

set -e

# Overwrite permission changes when mounting persistent volumes.
sudo chmod -R 777 /home

python3 -u /clone_nbs.py

# Disable formgrader.
sudo jupyter nbextension disable --sys-prefix formgrader/main --section=tree
sudo jupyter serverextension disable --sys-prefix nbgrader.server_extensions.formgrader

# Link data directory under notebooks to dataset directory if not already linked.
sudo rm -rf /home/${JUPYTERHUB_USER}/notebooks/data
sudo ln -fs /home/${JUPYTERHUB_USER}/data /home/${JUPYTERHUB_USER}/notebooks/data

if [[ ! -z "${MYSQL_HOST}" ]]; then
    if sudo service mysql status; then
        sudo service mysql stop
    fi
else
    sudo -E chown -R mysql:mysql ${MYSQL_DATA_DIR} ${MYSQL_RUN_DIR}; sudo service mysql start
fi

exec jupyter notebook --no-browser --allow-root $*
