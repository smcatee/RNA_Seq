#!/bin/bash

##Author: Sean McAtee
##Version: 1/22/2020

##About: This script will run through each step of mRNA Differential Expression Analysis as outlined in the workflow document.
# The following programs were set as PATH variables:
    SRA Toolkit, FASTX-Toolkit,
# The following programs were set as alias:
#   samtools,

currentDate=`date +"%F_%H%M"`
mkdir -p RNA_Seq_Run_${currentDate}/{SRA_Files/{Raw_BAM_Files,Trimmed_BAM_Files,QC_Output},Aligner_Output/{Trinity,BowTie,STAR,Oasis,QC}}
cd RNA_Seq_Run_${currentDate}

# Download SRA files
curl -o SRA_Files/Raw_BAM_Files/SRR9984971 https://sra-download.ncbi.nlm.nih.gov/traces/sra75/SRR/009750/SRR9984971
curl -o SRA_Files/Raw_BAM_Files/SRR9984973 https://sra-download.ncbi.nlm.nih.gov/traces/sra19/SRR/009750/SRR9984973
curl -o SRA_Files/Raw_BAM_Files/SRR9984974 https://sra-download.ncbi.nlm.nih.gov/traces/sra23/SRR/009750/SRR9984974


# Convert SRA to SAM and directly into BAM for FastQC and other tools
for f in SRA_Files/Raw_BAM_Files/*; do sam-dump ${f} | samtools view -bS - > "${f}.bam"; done

# Check that BAM files were created and erase SRA  ?maybe?


# Pass split PE reads to trimmomatic
#   use anon named pipes to pass data in <() or out >()
