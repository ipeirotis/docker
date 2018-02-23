FROM BASE_IMAGE

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
RUN pip3 install -U \
    notebook==5.2.* \
    jupyterhub==0.8.* \
    ipython

RUN jupyter nbextension install --system --py nbgrader --overwrite && \
    jupyter nbextension enable --system --py nbgrader && \
    jupyter serverextension enable --system --py nbgrader
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

RUN mkdir -p /srv/nbgrader/exchange && \
    chmod -R 777 /srv/nbgrader && \
    touch /.nbgrader.log && \
    chmod -R 777 /.nbgrader.log

USER $NB_USER
