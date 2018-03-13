FROM ubuntu:latest

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV PYTHONIOENCODING UTF-8

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

# install latest version of pip
RUN pip3 install -U pip

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

RUN pip3 install sql_magic mysqlclient

RUN apt-get update && apt-get install -y software-properties-common python-software-properties
RUN apt-get install apt-transport-https
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/' && \
    apt-get update && \
    apt-get install -y r-base

RUN R -e "install.packages(c('car', 'ggvis', 'ggplot2', 'tidyverse', 'Hmisc', 'knitr', 'sqldfm', 'plotly', 'reshape2', 'MASS', 'rmarkdown'), repos='https://cloud.r-project.org/')"

RUN chmod -R 777 /home
