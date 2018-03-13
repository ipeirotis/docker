FROM KUBERNETES_IMAGE

USER root

#install mysql
ENV MYSQL_USER=mysql \
    MYSQL_PASSWORD=dwdstudent2015 \
    MYSQL_DATA_DIR=/var/lib/mysql \
    MYSQL_RUN_DIR=/var/run/mysqld \
    MYSQL_LOG_DIR=/var/log/mysql

ENV MYSQL_ROOT_PASSWORD='dwdstudent2015'

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
        && apt-get install -y mysql-server \
        && apt-get install -y python3-mysqldb \
        && rm -rf /var/lib/apt/lists/* \
        && rm -rf ${MYSQL_DATA_DIR} \
        && mkdir -p ${MYSQL_DATA_DIR} ${MYSQL_RUN_DIR} \
        && chown -R mysql:mysql ${MYSQL_DATA_DIR} ${MYSQL_RUN_DIR} \
        && chmod 777 ${MYSQL_RUN_DIR} \
        && echo '[mysqld]\nskip-host-cache\nskip-name-resolve\nuser=mysql' > /etc/mysql/conf.d/docker.cnf

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

RUN mysqld --initialize-insecure --user=mysql

RUN chown -R mysql:mysql ${MYSQL_DATA_DIR} ${MYSQL_RUN_DIR} && \
    service mysql start && sleep 5 \
    && echo "; ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'; CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" | mysql -uroot

RUN echo "c.NotebookApp.password = 'sha1:44967f2c7dbb:4ae5e013fa8bae6fd8d4b8fa88775c0c5caeffbf'" >> /etc/jupyter/jupyter_notebook_config.py

EXPOSE 3306 8888
ARG FILE_PATH
COPY ${FILE_PATH}/start-notebook.sh /usr/local/bin/
COPY ${FILE_PATH}/data.yaml /

LABEL org.jupyter.service="jupyter"

USER $NB_USER
