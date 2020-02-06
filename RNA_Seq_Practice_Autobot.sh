#!/bin/bash

##Author: Sean McAtee
##Version: 1/22/2020

##About: This script will run through each step of mRNA Differential Expression Analysis as outlined in the workflow document.

currentDate=`date +"%Y_%m_%d"`
mkdir -p RNA_Seq_Run_${currentDate}/{SRA_Files/{Raw_BAM_Files,Trimmed_BAM_Files,QC_Output},Aligner_Output/{Trinity,BowTie,STAR,Oasis,QC}}

# Download SRA files
curl -O https://sra-download.ncbi.nlm.nih.gov/traces/sra75/SRR/009750/SRR9984971 | sam-dump | /Applications/samtools/view -bS
curl -O https://sra-download.ncbi.nlm.nih.gov/traces/sra19/SRR/009750/SRR9984973
curl -O https://sra-download.ncbi.nlm.nih.gov/traces/sra23/SRR/009750/SRR9984974

# Convert SRA to SAM and directly into BAM to save space
for f in *; do sam-dump ${f} | /Applications/samtools/view -bS - > "${f}.bam"; done

#