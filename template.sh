#!/bin/bash
#
# template.sh
# Base script to install nextflow

# We need Java first
wget https://corretto.aws/downloads/latest/amazon-corretto-21-x64-linux-jdk.tar.gz
tar -xzf amazon-corretto-21-x64-linux-jdk.tar.gz
rm amazon-corretto-21-x64-linux-jdk.tar.gz
# need to rename this for the exact latest version
export JAVA_HOME=$PWD/amazon-corretto-21.0.7.6.1-linux-x64
export PATH=$PWD/amazon-corretto-21.0.7.6.1-linux-x64/bin:$PATH

# Next we need to install Nextflow
curl -s https://get.nextflow.io | bash
chmod +x ./nextflow
# if a specific version is desired
# export NXF_VER=25.04.2
# ./nextflow self-update

# *********************************
# Here you will want to copy data to process from /staging
# Then move results back to staging
# *********************************

# clean up
rm -rf $JAVA_HOME
rm ./nextflow
