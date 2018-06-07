#!/bin/bash

set -e

if [[ ! -z "${JUPYTERHUB_API_TOKEN}" ]]; then
    # Launched by JupyterHub, use single-user entrypoint.
    # Create link to instructor's nbgrader config, for formgrader to work properly.
    if [ -e /home/${JUPYTERHUB_USER}/notebooks/nbgrader_config.py ]; then
        sudo ln -fs /home/${JUPYTERHUB_USER}/notebooks/nbgrader_config.py /etc/jupyter/nbgrader_config.py
    fi

    # Create local user for LDAP user.
    sudo useradd --home /home/${JUPYTERHUB_USER} -s /bin/bash -g ubuntu ${JUPYTERHUB_USER}

    sudo -n -E -u ${JUPYTERHUB_USER} python3 -u /clone_nbs.py

    # Link data directory under notebooks to dataset directory if not already linked.
    sudo rm -rf /home/${JUPYTERHUB_USER}/notebooks/data
    sudo ln -fs /home/${JUPYTERHUB_USER}/data /home/${JUPYTERHUB_USER}/notebooks/data

    # If this is a student server, remove formgrader.
    if [[ "$USER_IS_CLUSTER_ADMIN" == 0 ]]; then
        sudo jupyter nbextension disable --sys-prefix formgrader/main --section=tree
        sudo jupyter serverextension disable --sys-prefix nbgrader.server_extensions.formgrader
    else
        exec sudo -n -E -u ${JUPYTERHUB_USER} python3 -u /grading_service.py &
    fi

    exec sudo -n -E -u ${JUPYTERHUB_USER} jupyterhub-singleuser $*
else
    exec jupyter notebook $*
fi
