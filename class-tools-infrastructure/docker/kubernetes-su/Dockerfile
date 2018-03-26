FROM ipeirotis/dealing_with_data:base-latest

ENV NB_USER ubuntu

ARG GCLOUD_DATA
ENV DATA_BUCKET ${GCLOUD_DATA}

RUN useradd -ms /bin/bash ubuntu

RUN export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s` && \
    echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

RUN apt-get -y update && \
    apt-get -y install gcsfuse

# install basic Python libraries to run Jupyter
RUN pip3 install \
    notebook==5.2.2 \
    jupyterhub==0.8.1 \
    jupyterlab==0.31.10 \
    ipython==6.2.1

RUN jupyter nbextension install --system --py nbgrader --overwrite && \
    jupyter nbextension enable --system --py nbgrader && \
    jupyter serverextension enable --system --py nbgrader && \
    jupyter serverextension enable --system --py jupyterlab

RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - && \
    sudo apt-get install -y nodejs
RUN jupyter labextension install --debug @jupyterlab/hub-extension

ARG FILE_PATH

# Add a notebook profile.
COPY $FILE_PATH/jupyter_notebook_config.py /etc/jupyter/
RUN echo "c.NotebookApp.allow_root = True" >> /etc/jupyter/jupyter_notebook_config.py
RUN echo "ALL  ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN pip3 install ipython-sql

EXPOSE 8888
LABEL org.jupyter.service="jupyter"
RUN chmod -R 777 /home

CMD ["start-notebook.sh"]

# Add local files as late as possible to avoid cache busting
COPY $FILE_PATH/start-notebook.sh /usr/local/bin/
COPY $FILE_PATH/clone_nbs.py /
COPY $FILE_PATH/courses.yaml /
COPY $FILE_PATH/nbgrader_config.py /etc/jupyter/

RUN apt update && apt install -y mysql-client

RUN mkdir -p /srv/nbgrader/exchange && \
    chmod -R 777 /srv/nbgrader && \
    touch /.nbgrader.log && \
    chmod -R 777 /.nbgrader.log

RUN R -e "install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'devtools', 'uuid', 'digest'), repos='https://cloud.r-project.org/')" && \
    R -e "devtools::install_github('IRkernel/IRkernel')" && \
    R -e "IRkernel::installspec(user = FALSE)"

USER $NB_USER
