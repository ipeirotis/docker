FROM ipeirotis/dealing_with_data:base-latest

ENV NB_USER ubuntu

ARG GCLOUD_DATA
ARG DEBIAN_FRONTEND=noninteractive
ENV DATA_BUCKET ${GCLOUD_DATA}

RUN useradd -ms /bin/bash ubuntu

RUN export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s` && \
    echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

RUN apt-get -qy update && \
    apt-get -qy install gcsfuse

# install basic Python libraries to run Jupyter
RUN pip3 install \
    notebook==5.2.2 \
    jupyterhub==0.8.1 \
    jupyterlab==0.31.10 \
    ipython==6.2.1

RUN pip3 install --no-cache-dir \
    git+https://github.com/abenetopoulos/nbgrader@e3a0082

RUN pip3 install jupyter_contrib_nbextensions

RUN jupyter nbextension install --system --py nbgrader --overwrite && \
    jupyter nbextension enable --system --py nbgrader && \
    jupyter serverextension enable --system --py nbgrader && \
    jupyter serverextension enable --system --py jupyterlab
RUN jupyter contrib nbextension install --system
RUN jupyter nbextension enable --system collapsible_headings/main
RUN jupyter nbextension enable --system code_prettify/code_prettify
RUN jupyter nbextension enable --system codefolding/main
RUN jupyter nbextension enable --system codefolding/edit
RUN jupyter nbextension enable --system exercise2/main
RUN jupyter nbextension enable --system spellchecker/main

RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - && \
    sudo apt-get install -qy nodejs
RUN jupyter labextension install --debug @jupyterlab/hub-extension@0.8.1

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

RUN apt update && apt install -y mysql-client

RUN mkdir -p /srv/nbgrader/exchange && \
    chmod -R 777 /srv/nbgrader && \
    touch /.nbgrader.log && \
    chmod -R 777 /.nbgrader.log

RUN R -e "install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'devtools', 'uuid', 'digest'), repos='https://cloud.r-project.org/')" && \
    R -e "devtools::install_github('IRkernel/IRkernel')" && \
    R -e "IRkernel::installspec(user = FALSE)"

# Add local files as late as possible to avoid cache busting
COPY $FILE_PATH/start-notebook.sh /usr/local/bin/
COPY $FILE_PATH/clone_nbs.py /
COPY $FILE_PATH/courses.yaml /
COPY $FILE_PATH/nbgrader_config.py /etc/jupyter/
COPY $FILE_PATH/grading_service.py /

USER $NB_USER
