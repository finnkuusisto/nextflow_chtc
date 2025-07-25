#!/bin/bash
#
# rnaseq_template.sh
# Base script to run nextflow rnaseq pipeline

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
wget https://github.com/hartwigmedical/testdata/raw/refs/heads/master/100k_reads_hiseq/TESTX/TESTX_H7YRLADXX_S1_L001_R1_001.fastq.gz
wget https://github.com/hartwigmedical/testdata/raw/refs/heads/master/100k_reads_hiseq/TESTX/TESTX_H7YRLADXX_S1_L001_R2_001.fastq.gz
# the sample sheet indicates sample names and FASTQs
echo -e "sample,fastq_1,fastq_2,strandedness\nTESTX_H7YRLADXX_S1_L001,TESTX_H7YRLADXX_S1_L001_R1_001.fastq.gz,TESTX_H7YRLADXX_S1_L001_R2_001.fastq.gz,reverse" >> samplesheet.csv

# *********************************
# Grab the FASTAs and GTF
# *********************************
wget https://ftp.ensembl.org/pub/release-114/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
wget https://ftp.ensembl.org/pub/release-114/gtf/homo_sapiens/Homo_sapiens.GRCh38.114.gtf.gz


# *********************************
# Run your Nextflow pipeline (apptainer profile)
# Apptainer is already installed on CHTC nodes
# *********************************
mkdir $OUTDIR
# need this on the CHTC machines - defaults to no execution
echo -e "process {\n  beforeScript = 'chmod +x .command.run'\n}" >> nextflow.config
./nextflow run nf-core/rnaseq \
  -c nextflow.config \
  --input ./samplesheet.csv \
  --outdir $OUTDIR \
  --gtf Homo_sapiens.GRCh38.114.gtf.gz \
  --fasta Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz \
  --pseudo_aligner kallisto \
  --skip_alignment \
  --trimmer fastp \
  -profile apptainer

# *********************************
# Copy output data from pipeline to /staging or
# *********************************

# *********************************
# Clean up data not needed further
# *********************************
rm Homo_sapiens.GRCh38.cdna.all.fa.gz
rm Homo_sapiens.GRCh38.114.gtf.gz

rm nextflow.config
rm samplesheet.csv
rm TESTX_H7YRLADXX_S1_L001_R1_001.fastq.gz
rm TESTX_H7YRLADXX_S1_L001_R2_001.fastq.gz

# *********************************
# Clean up software
# *********************************
rm -rf $JAVA_HOME
rm ./nextflow
