FROM ubuntu:latest

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV PYTHONIOENCODING UTF-8
ENV NB_USER ubuntu

ARG GCLOUD_DATA
ENV DATA_BUCKET ${GCLOUD_DATA}

RUN useradd -ms /bin/bash ubuntu

RUN apt-get -y update && \
    apt-get -y dist-upgrade && \
    apt-get -y upgrade && \
    apt-get -y install \
        sudo \
        build-essential \
        python3-dev \
        python3-pip \
        ca-certificates \
        curl \
        git \
        gfortran \
        libblas-dev \
        liblapack-dev \
        libssl-dev \
        libffi-dev \
        libcurl4-openssl-dev \
        libgdal-dev \
        lsb-release \
        lsb-core \
        wget \
        jq \
        language-pack-en \
        libcurl4-openssl-dev \
        libffi-dev \
        libzmq3-dev \
        libxml2-dev \
        libxslt-dev \
        python3-lxml \
        zlib1g-dev \
    python3-mysqldb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s` && \
    echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

RUN apt-get -y update && \
    apt-get -y install gcsfuse

# install latest version of pip
RUN pip3 install -U pip

# TODO: Move the Python libraries to a requirements.txt file?

# install basic Python libraries to run Jupyter
RUN pip3 install -U \
    notebook==5.2.* \
    jupyterhub==0.8.* \
    ipython

# add libraries used in intro to python exercise
RUN pip3 install -U jellyfish \
    ngram

# add standard data science libraries
RUN pip3 install -U \
    numpy \
    scipy \
    matplotlib \
    pandas \
    statsmodels \
    scikit-learn

# add libraries for teaching web APIs
RUN pip3 install -U \
    requests \
    requests_oauthlib \
    Flask \
    slackclient

# add libraries for NLP
RUN pip3 install -U \
    spacy \
    nltk \
    gensim

# add libraries for visualization/mapping
RUN pip3 install -U \
    seaborn \
    bokeh \
    folium \
    geopandas \
    geopy

# add libraries for finance
RUN pip3 install -U \
    googlefinance \
    yahoo-finance \
    quandl

# misc libraries
RUN pip3 install -U \
    boto \
    boto3 \
    elasticsearch \
    nbgrader \
    networkx \
    py2neo \
    pymongo \
    selenium \
    pyyaml \
    gitpython \
    tweepy

RUN jupyter nbextension install --system --py nbgrader --overwrite && \
    jupyter nbextension enable --system --py nbgrader && \
    jupyter serverextension enable --system --py nbgrader
ARG FILE_PATH
# Add a notebook profile.
COPY $FILE_PATH/jupyter_notebook_config.py /etc/jupyter/
RUN echo "c.NotebookApp.allow_root = True" >> /etc/jupyter/jupyter_notebook_config.py
RUN echo "ALL  ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN pip3 install ipython-sql sql_magic mysqlclient

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
