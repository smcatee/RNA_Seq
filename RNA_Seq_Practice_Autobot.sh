#!/bin/bash

##Author: Sean McAtee
##Version: 2/16/2020

##About: This script will run through each step of mRNA Differential Expression Analysis as outlined in the workflow document.

# PATH variables:
#   SRA Toolkit, FASTX-Toolkit
# Program path variables:
fastqc=/Applications/FastQC.app/Contents/MacOS/fastqc
trimmomatic=/Applications/Trimmomatic-0.39/trimmomatic-0.39.jar
trinity=/Applications/trinityrnaseq-v2.9.1/Trinity


# Enter the accession number that you would like to run through Autobot
#   Tested on: SRR9984971, SRR9984973, SRR9984974
SRA_Accession_Number="SRR9984971"


# Variables for parameter testing
#Trimmomatic:
Trimmomatic_seed_mismatches=2 #[]
Trimmomatic_palindrome_clip_threshold=40 #[]
Trimmomatic_simple_clip_threshold=15 #[]
Trimmomatic_minAdapterLength=8 #[]
Trimmomatic_fasta_adaptor_file="/Applications/Trimmomatic-0.39/adapters/adapters_cat.fa" #/path/to/file
Trimmomatic_windowSize=4 #[]
Trimmomatic_requiredQuality=15 #[20-40]
Trimmomatic_targetLength=40 #[ -150]
Trimmomatic_strictness=0.9 #[0-1]
Trimmomatic_quality_leading=20 #[10-30]
Trimmomatic_quality_trailing=20 #[10-30]
Trimmomatic_head_crop_length=10 #[]
Trimmomatic_minLen=50 #[ -150]

illuminaClip="ILLUMINACLIP:${Trimmomatic_fasta_adaptor_file}:${Trimmomatic_seed_mismatches}:${Trimmomatic_palindrome_clip_threshold}:${Trimmomatic_simple_clip_threshold}:${Trimmomatic_minAdapterLength}:TRUE "
slidingWindow="SLIDINGWINDOW:${Trimmomatic_windowSize}:${Trimmomatic_requiredQuality} "
maxInfo="MAXINFO:${Trimmomatic_targetLength}:${Trimmomatic_strictness} "
trimmLEADING="LEADING:${Trimmomatic_quality_leading} "
trimmTRAILING="TRAILING:${Trimmomatic_quality_trailing} "
trimmHeadCrop="HEADCROP:${Trimmomatic_head_crop_length} "
minLen="MINLEN:${Trimmomatic_minLen} "

trimmingMethod=${maxInfo} # $slidingWindow or $maxInfo

trimmomaticParameters=${illuminaClip}${trimmingMethod}${trimmLEADING}${trimmTRAILING}${trimmHeadCrop}${minLen}

currentDate=`date +"%F_%H%M"`



# Setup directory tree and move to working directory
echo "Setting up directory"
mkdir -p RNA_Seq_Practice_Run_${currentDate}/${SRA_Accession_Number}/{SRA_Files/{Raw_Files,Trimmed_Files,QC_Output},Aligner_Output/{Trinity,BowTie,STAR,Oasis,QC}}
cd RNA_Seq_Practice_Run_*/SRR9984971/

# Download split fastq reads for trimmomatic
echo "Downloading fastq files"
fastq-dump --split-files -O SRA_Files/Raw_Files/ --gzip ${SRA_Accession_Number}


# Re-download to perform hashsum check
echo "Redownloading fastq files in a temp folder to check hashsum"
mkdir -p ./temp/Raw_Files/
fastq-dump --split-files -O ./temp/Raw_Files/ --gzip ${SRA_Accession_Number}

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


# Trimming commands (replace repetative file names with variable expansion)
#  Keeps paired trim reads and discards unpaired trim reads
mkdir -p ./temp/unpairedReads/
java -jar ${trimmomatic} PE ./SRA_Files/Raw_Files/*1.fastq.gz ./SRA_Files/Raw_Files/*2.fastq.gz ./SRA_Files/Trimmed_Files/lane1_forward_paired.fq.gz ./temp/unpairedReads/f_unpaired.fq.gz ./SRA_Files/Trimmed_Files/lane1_reverse_paired.fq.gz ./temp/unpairedReads/r_unpaired.fq.g "${trimmomaticParameters}"
rm -r ./temp/unpairedReads/


# Run both trimmed and raw reads through FastQC
${fastqc} ./SRA_Files/Trimmed_Files/*fq.gz --outdir=./SRA_Files/QC_Output/
${fastqc} ./SRA_Files/Raw_Files/*.fastq.gz --outdir=./SRA_Files/QC_Output/


# Pause?

# Trinity
#trinity --seqType fq --max_memory <int>G --left <string> --right <string> --CPU 2 --min_contig_length 200 --no_normalize_reads --output <string> --version

rm -r ./temp/
