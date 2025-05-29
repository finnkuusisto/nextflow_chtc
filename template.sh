#!/bin/bash
#
# template.sh
# Base script to install nextflow

# We need Java first
# NOTE: update as needed for latest version
# NOTE: https://docs.aws.amazon.com/corretto/latest/corretto-21-ug/downloads-list.html
wget https://corretto.aws/downloads/resources/21.0.7.6.1/amazon-corretto-21.0.7.6.1-linux-x64.tar.gz
tar -xzf amazon-corretto-21.0.7.6.1-linux-x64.tar.gz
rm amazon-corretto-21.0.7.6.1-linux-x64.tar.gz
export JAVA_HOME=$PWD/amazon-corretto-21.0.7.6.1-linux-x64
export PATH=$PWD/amazon-corretto-21.0.7.6.1-linux-x64/bin:$PATH

# Next we need to install Nextflow
curl -s https://get.nextflow.io | bash
chmod +x ./nextflow
# if a specific version is desired
# export NXF_VER=25.04.2
# ./nextflow self-update

# *********************************
# Copy input data to process from /staging
# *********************************

# *********************************
# Run your Nextflow pipeline (apptainer profile)
# Apptainer is already installed on CHTC nodes
# *********************************

# *********************************
# Copy output data from pipeline to /staging
# *********************************

# clean up
rm -rf $JAVA_HOME
rm ./nextflow
