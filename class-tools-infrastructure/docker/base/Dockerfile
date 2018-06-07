FROM ubuntu:18.04

ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV PYTHONIOENCODING UTF-8

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -qy update && \
        apt-get -qy dist-upgrade && \
        apt-get -qy upgrade && \
        apt-get -qy install \
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
        pandoc \
        texlive-xetex \
        fonts-humor-sans \
        python3-mysqldb && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

# install latest version of pip
RUN pip3 install -U pip
RUN pip3 install tornado==4.5.3

RUN pip3 install autopep8 yapf

# add libraries used in intro to python exercise
RUN pip3 install jellyfish \
    ngram

# add support for SQL
RUN pip3 install \
    sql_magic \
    mysqlclient

# add standard data science libraries
RUN pip3 install \
    numpy \
    scipy \
    matplotlib \
    pandas \
    statsmodels \
    scikit-learn

# add libraries for teaching web APIs
RUN pip3 install \
    requests \
    requests_oauthlib \
    Flask \
    slackclient \
    pillow \
    tweepy

# add libraries for NLP
RUN pip3 install \
    spacy \
    nltk \
    gensim

# add libraries for visualization/mapping
RUN pip3 install \
    seaborn \
    bokeh \
    folium \
    geopandas \
    geopy

# add libraries for finance
RUN pip3 install \
    googlefinance \
    yahoo-finance \
    quandl

# misc libraries
RUN pip3 install \
    boto \
    boto3 \
    elasticsearch \
    networkx \
    py2neo \
    pymongo \
    selenium \
    pyyaml \
    gitpython



# for data mining class
RUN pip3 install \
    graphviz \
    liac-arff \
    pydotplus

RUN apt-get update && apt-get install -qy software-properties-common
RUN apt-get install -qy apt-transport-https
RUN apt-get install -qy r-base

RUN R -e "install.packages(c('car', 'ggvis', 'ggplot2', 'tidyverse', 'Hmisc', 'knitr', 'sqldfm', 'plotly', 'reshape2', 'MASS', 'rmarkdown'), repos='https://cloud.r-project.org/')"


RUN chmod -R 777 /home
