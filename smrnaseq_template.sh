#!/bin/bash
#
# smrnaseq_template.sh
# Base script to run nextflow smrnaseq pipeline

OUTDIR=./output

# We need Java first
# NOTE: update as needed for latest version
# NOTE: https://docs.aws.amazon.com/corretto/latest/corretto-21-ug/downloads-list.html
wget https://corretto.aws/downloads/resources/21.0.7.6.1/amazon-corretto-21.0.7.6.1-linux-x64.tar.gz
tar -xzf amazon-corretto-21.0.7.6.1-linux-x64.tar.gz
rm amazon-corretto-21.0.7.6.1-linux-x64.tar.gz
export JAVA_HOME=$PWD/amazon-corretto-21.0.7.6.1-linux-x64
export PATH=$PWD/amazon-corretto-21.0.7.6.1-linux-x64/bin:$PATH

# Next we need to install Nextflow
export NXF_HOME=$PWD
curl -s https://get.nextflow.io | bash
chmod +x ./nextflow
# if a specific version is desired
# export NXF_VER=25.04.2
# ./nextflow self-update

# *********************************
# Copy input data to process from /staging or elsewhere
# *********************************
cp /staging/groups/surgery_brown_group/finn/mirna/ERR15277928.fastq .
gzip ERR15277928.fastq
# the sample sheet indicates sample names and FASTQs
# smrnaseq can accomodate paired end in the sample sheet but only uses the first
echo -e "sample,fastq_1,fastq_2\nERR15277928,ERR15277928.fastq.gz," >> samplesheet.csv

# *********************************
# Run your Nextflow pipeline (apptainer profile)
# Apptainer is already installed on CHTC nodes
# *********************************
mkdir $OUTDIR
# need this on the CHTC machines - defaults to no execution
echo -e "process {\n  beforeScript = 'chmod +x .command.run'\n}" >> nextflow.config
./nextflow run nf-core/smrnaseq \
  -c nextflow.config \
  --input ./samplesheet.csv \
  --outdir $OUTDIR \
  --genome GRCh37 \
  --mirtrace_species hsa \
  -profile apptainer,illumina

# *********************************
# Copy output data from pipeline to /staging or
# *********************************
zip -r ${OUTDIR}.zip $OUTDIR

# *********************************
# Clean up data not needed further
# *********************************
rm nextflow.config
rm samplesheet.csv
rm ERR15277928.fastq.gz

# *********************************
# Clean up software
# *********************************
rm -rf $JAVA_HOME
rm ./nextflow
