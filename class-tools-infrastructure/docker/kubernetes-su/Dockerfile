FROM ipeirotis/dealing_with_data:base-latest

ENV NB_USER ubuntu

ARG GCLOUD_DATA
ARG DEBIAN_FRONTEND=noninteractive
ENV DATA_BUCKET ${GCLOUD_DATA}

RUN useradd -ms /bin/bash ubuntu

RUN apt-get -qy update
# install basic Python libraries to run Jupyter
# RUN pip3 install \
#     notebook==5.2.2 \
#    jupyterhub==0.8.1 \
#    jupyterlab==0.31.10 \
#    ipython==6.2.1

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

EXPOSE 8888
LABEL org.jupyter.service="jupyter"
RUN chmod -R 777 /home

CMD ["start-notebook.sh"]

RUN apt update && apt install -y mysql-client


# RUN R -e "install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'devtools', 'uuid', 'digest'), repos='https://cloud.r-project.org/')" && \

RUN R -e "install.packages(c('devtools'), repos='https://cloud.r-project.org/')"

RUN   R -e "devtools::install_github('IRkernel/IRkernel')" && \
      R -e "IRkernel::installspec(user = FALSE)"

# Add local files as late as possible to avoid cache busting
COPY $FILE_PATH/start-notebook.sh /usr/local/bin/
COPY $FILE_PATH/clone_nbs.py /
COPY $FILE_PATH/courses.yaml /

USER $NB_USER
