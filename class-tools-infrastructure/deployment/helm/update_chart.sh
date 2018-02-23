#!/bin/bash

if [ "$#" -lt "1" ]; then
    echo "USAGE: ./update_chart.sh gcs_bucket_name [chart_folder]"
    exit 1
fi

HELM_REPO=$1
CHART_FOLDER=${2:-"zero-to-jupyterhub-k8s/jupyterhub"}

echo "> Will package chart"
helm package $CHART_FOLDER
echo "> Done"

mkdir -p jupyter-chart
mv jupyterhub-*.tgz jupyter-chart

echo "> Will generate chart index"
helm repo index jupyter-chart/ --url https://$HELM_REPO.storage.googleapis.com
echo "> Done"

echo "> Will upload to $HELM_REPO bucket"
gsutil cp jupyter-chart/* gs://$HELM_REPO/
echo "> Done"
