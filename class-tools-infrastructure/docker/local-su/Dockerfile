FROM ipeirotis/dealing_with_data:base-latest

ENV NB_USER ubuntu

ARG GCLOUD_DATA
ARG DEBIAN_FRONTEND=noninteractive
ENV DATA_BUCKET ${GCLOUD_DATA}

RUN useradd -ms /bin/bash ubuntu

RUN apt-get -qy update

# install basic Python libraries to run Jupyter
RUN pip3 install \
    notebook \
    jupyterhub \
#    jupyterlab \
    ipython


RUN pip3 install jupyter_contrib_nbextensions

#    && \
#    jupyter serverextension enable --system --py jupyterlab
RUN jupyter contrib nbextension install --system
RUN jupyter nbextension enable --system collapsible_headings/main
RUN jupyter nbextension enable --system code_prettify/code_prettify
RUN jupyter nbextension enable --system codefolding/main
RUN jupyter nbextension enable --system codefolding/edit
RUN jupyter nbextension enable --system exercise2/main
RUN jupyter nbextension enable --system spellchecker/main

RUN jupyter nbextension install --system https://rawgit.com/jfbercher/small_nbextensions/master/toc2.zip
RUN jupyter nbextension enable --system  toc2/main

RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - && \
    sudo apt-get install -qy nodejs
# RUN jupyter labextension install --debug @jupyterlab/hub-extension@0.8.1

ARG FILE_PATH

# Add a notebook profile.
COPY $FILE_PATH/jupyter_notebook_config.py /etc/jupyter/
RUN echo "c.NotebookApp.allow_root = True" >> /etc/jupyter/jupyter_notebook_config.py
RUN echo "ALL  ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN pip3 install ipython-sql

RUN chmod -R 777 /home

RUN apt update && apt install -y mysql-client


# RUN R -e "install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'devtools', 'uuid', 'digest'), repos='https://cloud.r-project.org/')" && \

RUN R -e "install.packages(c('devtools'), repos='https://cloud.r-project.org/')"

RUN   R -e "devtools::install_github('IRkernel/IRkernel')" && \
      R -e "IRkernel::installspec(user = FALSE)"

# Here starts the set up of the local environment

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
        && apt-get install -qy mysql-server \
        && apt-get install -qy python3-mysqldb \
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

COPY ${FILE_PATH}/start-notebook.sh /usr/local/bin/
COPY ${FILE_PATH}/data.yaml /
COPY $FILE_PATH/clone_nbs.py /
COPY $FILE_PATH/courses.yaml /

LABEL org.jupyter.service="jupyter"

USER $NB_USER

CMD ["start-notebook.sh"]
