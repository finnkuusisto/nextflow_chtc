#!/bin/bash
#
# hlatyping_template.sh
# Base script to run nextflow hlatyping pipeline

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
wget https://raw.githubusercontent.com/FRED-2/OptiType/refs/heads/master/test/exome/NA11995_SRR766010_1_fished.fastq
wget https://raw.githubusercontent.com/FRED-2/OptiType/refs/heads/master/test/exome/NA11995_SRR766010_2_fished.fastq
# the hlatyping pipeline requires FASTQs to be gziped
gzip NA11995_SRR766010_1_fished.fastq
gzip NA11995_SRR766010_2_fished.fastq
# the sample sheet indicates sample names and FASTQs
echo -e "sample,fastq_1,fastq_2,seq_type\ntest,NA11995_SRR766010_1_fished.fastq.gz,NA11995_SRR766010_2_fished.fastq.gz,dna" >> samplesheet.csv

# *********************************
# Run your Nextflow pipeline (apptainer profile)
# Apptainer is already installed on CHTC nodes
# *********************************
mkdir $OUTDIR
# need this on the CHTC machines - defaults to no execution
echo -e "process {\n  beforeScript = 'chmod +x .command.run'\n}" >> nextflow.config
# hlatyping includes a step that tries to write to $HOME which defaults read only
export HOME=$OUTDIR
# actually run it
./nextflow run nf-core/hlatyping \
  -c nextflow.config \
  --input ./samplesheet.csv \
  --outdir $OUTDIR \
  --genome GRCh37 \
  -profile apptainer

# *********************************
# Copy output data from pipeline to /staging or
# *********************************
zip -r ${OUTDIR}.zip $OUTDIR

# *********************************
# Clean up data not needed further
# *********************************
rm nextflow.config
rm samplesheet.csv
rm NA11995_SRR766010_*.fastq.gz

# *********************************
# Clean up software
# *********************************
rm -rf $JAVA_HOME
rm ./nextflow
