#!/bin/bash

##Author: Sean McAtee
##Version: 2/16/2020

##About: This script will run through each step of mRNA Differential Expression Analysis as outlined in the workflow document.

# PATH variables:
#   SRA Toolkit, FASTX-Toolkit
# Alias variable names:
#   alias samtools='/Applications/samtools/samtools'
#   alias trimmomatic='java -jar /Applications/Trimmomatic-0.39/trimmomatic-0.39.jar'


# Enter the accession number that you would like to run through Autobot
#   Tested on: SRR9984971, SRR9984973, SRR9984974
SRA_Accession_Number="SRR9984971"

currentDate=`date +"%F_%H%M"`


# Setup directory tree and move to working directory
echo "Setting up directory"
mkdir -p RNA_Seq_Practice_Run_${currentDate}/${SRA_Accession_Number}/{SRA_Files/{Raw_Files,Trimmed_Files,QC_Output},Aligner_Output/{Trinity,BowTie,STAR,Oasis,QC}}
cd RNA_Seq_Practice_Run_${currentDate}/${SRA_Accession_Number}/

# Download split fastq reads for trimmomatic
echo "Downloading fastq files"
fastq-dump --split-files -O SRA_Files/Raw_Files/ ${SRA_Accession_Number}

# Re-download to perform hashsum check
echo "Redownloading fastq files in a temp folder to check hashsum"
mkdir -p ./temp/Raw_Files/
fastq-dump --split-files -O ./temp/Raw_Files/ ${SRA_Accession_Number}

# If hashsum values are not equal re-download up to 10 times, else quit with error message
loopCount=0
while [[ 0x`openssl dgst -sha1 -binary ./SRA_Files/Raw_Files/* | xxd -p -c 1000` -ne 0x`openssl dgst -sha1 -binary ./SRA_Files/Raw_Files/* | xxd -p -c 1000` ]] && (( ${loopCount} < 5))
do
rm ./SRA_Files/Raw_Files/*
mv ./temp/Raw_Files/* ./SRA_Files/Raw_Files/
fastq-dump --split-files -O ./temp/Raw_Files/ ${SRA_Accession_Number}
loopCount=$((loopCount+1))
echo "Checked hashsum ${loopCount} times. Autobot will redownload and eventually quit after 5 times"
done
rm -r ./temp/Raw_Files/


# Run reads through trimmomatic

# Run both trimmed and raw reads through FastQC

# Compress raw reads files and erase uncompressed versions

# Pause to give user options for proceeding steps based on FastQC output
#   Options: