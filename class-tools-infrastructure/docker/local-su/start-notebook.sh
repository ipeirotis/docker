#!/bin/bash

set -e

# Overwrite permission changes when mounting persistent volumes.
sudo chmod -R 777 /home

python3 -u /clone_nbs.py

# Link data directory under notebooks to dataset directory if not already linked.
sudo rm -rf /home/${NB_USER}/notebooks/data
sudo ln -fs /home/${NB_USER}/data /home/${NB_USER}/notebooks/data

if [[ ! -z "${MYSQL_HOST}" ]]; then
    if sudo service mysql status; then
        sudo service mysql stop
    fi
elif [ $(find "$MYSQL_DATA_DIR" -mindepth 1 -maxdepth 1 \! -name 'lost+found' | wc -l) -eq 0  ]; then
    echo "Empty MySQL directory"
    if sudo service mysql status; then
        sudo service mysql stop
    fi
    sudo chown -R mysql:mysql ${MYSQL_DATA_DIR} ${MYSQL_RUN_DIR}
# lost+found directory has to be deleted first in order to initiliaze
    sudo rm -rf /var/lib/mysql/*
    sudo mysqld --initialize-insecure --user=mysql
    sudo -E chown -R mysql:mysql ${MYSQL_DATA_DIR} ${MYSQL_RUN_DIR}; sudo service mysql start
# copy password value from debian.cnf file and create user
    debian_sys_password=$(sudo awk -F'= ' '/^password/{print $2}' /etc/mysql/debian.cnf | head -1)
    mysql -uroot -e "GRANT ALL PRIVILEGES on *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '${debian_sys_password}' WITH GRANT OPTION;FLUSH PRIVILEGES;"
    mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';FLUSH PRIVILEGES;"
else
    echo "Found MySQL directory"
    sudo -E chown -R mysql:mysql ${MYSQL_DATA_DIR} ${MYSQL_RUN_DIR}; sudo service mysql start
fi

exec jupyter notebook --no-browser --allow-root $*
