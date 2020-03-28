#!/bin/bash

SRA_Accession_Number="SRR9984971"

# Setup directory tree and move to working directory
echo "Setting up directory"
currentDate=`date +"%F_%H%M"`
mkdir -p RNA_Seq_Practice_Run_${currentDate}/${SRA_Accession_Number}/{SRA_Files/{Raw_Files,Trimmed_Files,QC_Output},Aligner_Output/{Trinity,BowTie,STAR,Oasis,QC}}
cd RNA_Seq_Practice_Run_*/${SRA_Accession_Number}/


# Download split fastq files
echo "Downloading fastq files"
fasterq-dump --split-files -O SRA_Files/Raw_Files/ ${SRA_Accession_Number} -p

# Re-download to perform hashsum check
echo "Redownloading fastq files in a temp folder to check hashsum"
mkdir -p ./temp/Raw_Files/
fasterq-dump --split-files -O ./temp/Raw_Files/ ${SRA_Accession_Number} -p

# If hashsum values are not equal re-download up to 10 times, else quit with error message
echo "Calculating hashsums"
loopCount=0
while [[ 0x`openssl dgst -sha1 -binary ./SRA_Files/Raw_Files/* | xxd -p -c 1000` -ne 0x`openssl dgst -sha1 -binary ./SRA_Files/Raw_Files/* | xxd -p -c 1000` ]] && (( ${loopCount} < 5))
do
    rm ./SRA_Files/Raw_Files/*
    mv ./temp/Raw_Files/* ./SRA_Files/Raw_Files/
    fasterq-dump --split-files -O ./temp/Raw_Files/ ${SRA_Accession_Number} -p
    loopCount=$((loopCount+1))
    echo "Checked hashsum ${loopCount} times. Autobot will redownload and eventually quit after 5 times"
done
rm -r ./temp/Raw_Files/

echo "Compressing fastq files"
gzip --fast ./SRA_Files/Raw_Files/*.f*q
