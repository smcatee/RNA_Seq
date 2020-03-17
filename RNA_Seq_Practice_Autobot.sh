#!/bin/bash
shopt -s extglob # necessary?? for using sed with -E

##Author: Sean McAtee
##Version: 2/16/2020
##Developed on MacOS Sierra 10.12.6, some incompatabilities may exist with Linux GNU

##About: This script will run through each step of mRNA Differential Expression Analysis as outlined in the workflow document.
##          Autobot is intended to serve as a framework to help develop a pipeline faster
##              different trimming outputs will serve the place of multiple biological samples
##              parameter testing will help develop a hypothesis for real experiment parameters



####### Ú◊ ÁÎ ÚÁ ÔÎ ÇÇ     T E S T I N G   N O T E S    Ó ˜˜ Ô◊ ÁÔ Ó˝ ÎÁ Ç˝ Ç ˇÍ
####   Remember to edit line 60 to cd into the correctly dated directory
####   paired reads are denoted *1.fq.gz or *2.fq.gz before the file type for paired; unpaired reads are denoted *1u.fq.gz or *2u.fq.gz



# PATH variables:
#   SRA Toolkit, FASTX-Toolkit
# Program path variables:
fastqc=/Applications/FastQC.app/Contents/MacOS/fastqc
trimmomatic=/Applications/Trimmomatic-0.39/trimmomatic-0.39.jar
solexaqa=/Applications/SolexaQA++_v3.1.7.1/MacOs_10.7+/SolexaQA++
trinity=/Applications/trinityrnaseq-v2.9.1/Trinity


# Enter the accession number that you would like to run through Autobot
#   Tested on: SRR9984971, SRR9984973, SRR9984974
SRA_Accession_Number="SRR9984971"


# Variables for parameter testing
#Trimmomatic:
Trimmomatic_head_crop_length=10 #[]
Trimmomatic_fasta_adaptor_file="/Applications/Trimmomatic-0.39/adapters/adapters_cat.fa" #/path/to/file
Trimmomatic_seed_mismatches=2 #[]
Trimmomatic_palindrome_clip_threshold=40 #[]
Trimmomatic_simple_clip_threshold=15 #[]
Trimmomatic_minAdapterLength=8 #[]
Trimmomatic_windowSize=4 #[]
Trimmomatic_requiredQuality=15 #[20-40]
Trimmomatic_targetLength=40 #[ -150]
Trimmomatic_strictness=0.9 #[0-1]
Trimmomatic_quality_leading=20 #[10-30]
Trimmomatic_quality_trailing=20 #[10-30]
Trimmomatic_minLen=50 #[ -150]

trimmHeadCrop="HEADCROP:${Trimmomatic_head_crop_length} "
illuminaClip="ILLUMINACLIP:${Trimmomatic_fasta_adaptor_file}:${Trimmomatic_seed_mismatches}:${Trimmomatic_palindrome_clip_threshold}:${Trimmomatic_simple_clip_threshold}:${Trimmomatic_minAdapterLength}:TRUE "
slidingWindow="SLIDINGWINDOW:${Trimmomatic_windowSize}:${Trimmomatic_requiredQuality} "
maxInfo="MAXINFO:${Trimmomatic_targetLength}:${Trimmomatic_strictness} "
trimmLEADING="LEADING:${Trimmomatic_quality_leading} "
trimmTRAILING="TRAILING:${Trimmomatic_quality_trailing} "
minLen="MINLEN:${Trimmomatic_minLen} "

trimmingMethod=${maxInfo} # $slidingWindow or $maxInfo
trimmomaticParameters=${trimmHeadCrop}${illuminaClip}${trimmingMethod}${trimmLEADING}${trimmTRAILING}${minLen}

#SolexaQA++
SolexaQA_probcutoff=0.5 # [0-1]
SolexaQA_phredcutoff=13 # [0-41]
SolexaQA_BWA="" # ["--bwa" | ""]

SolexaQA_cutoff="--probcutoff ${SolexaQA_probcutoff}" # ["--probcutoff ${SolexaQA_probcutoff}" | "--phredcutoff ${SolexaQA_phredcutoff}"]




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



## Trimming commands
for sample in ./SRA_Files/Raw_Files/*1.f*q.gz
do
    sampleName=`echo ${sample} | sed -e "s/^\.\/SRA_Files\/Raw_Files\///" -Ee "s/[12]u?\.f.*q\.gz$//"`

    # Trimmomatic Subshell
    echo "Initiating Trimmmomatic subshell"
    (echo "Running Trimmomatic with parameters:"
    echo "${trimmomaticParameters}"
    java -jar ${trimmomatic} PE ./SRA_Files/Raw_Files/${sampleName}1.f*q.gz ./SRA_Files/Raw_Files/${sampleName}2.fastq.gz ./SRA_Files/Trimmed_Files/trimmomatic_${sampleName}1.fq.gz ./SRA_Files/Trimmed_Files/trimmomatic_${sampleName}1u.fq.gz ./SRA_Files/Trimmed_Files/trimmomatic_${sampleName}2.fq.gz ./SRA_Files/Trimmed_Files/trimmomatic_${sampleName}2u.fq.gz ${trimmomaticParameters}) &

    # SolexaQA++ with Trimmomatic Headcrop Subshell
    java -jar ${trimmomatic} SE ./SRA_Files/Raw_Files/${sampleName}1.f*q.gz ./SRA_Files/Trimmed_Files/headcrop_${sampleName}1.fq.gz HEADCROP:${Trimmomatic_head_crop_length}
    java -jar ${trimmomatic} SE ./SRA_Files/Raw_Files/${sampleName}2.f*q.gz ./SRA_Files/Trimmed_Files/headcrop_${sampleName}2.fq.gz HEADCROP:${Trimmomatic_head_crop_length}
    echo "Initiating SolexaQA subshell"
    (${solexaqa} dynamictrim ./SRA_Files/Trimmed_Files/headcrop_${sampleName}1.fq.gz ${SolexaQA_cutoff} ${SolexaQA_BWA} --directory ./temp/ --illumina
    # output to temp, rename & move trimmed file, later erase all other junk
    mv ./temp/*.gz "./SRA_Files/Trimmed_Files/solexaqa_${sampleName}1.fq.gz"
    ${solexaqa} dynamictrim ./SRA_Files/Trimmed_Files/headcrop_${sampleName}2.fq.gz ${SolexaQA_cutoff} ${SolexaQA_BWA} --directory ./temp/ --illumina
    mv ./temp/*.gz "./SRA_Files/Trimmed_Files/solexaqa_${sampleName}2.fq.gz")
    wait
done
rm ./temp/*


# Run both trimmomatic, solexa, and raw reads through FastQC
(${fastqc} ./SRA_Files/Trimmed_Files/*fq.gz --outdir=./SRA_Files/QC_Output/) &
(${fastqc} ./SRA_Files/Raw_Files/*.fastq.gz --outdir=./SRA_Files/QC_Output/) &
wait
rm ./SRA_Files/QC_Output/*.zip

# Pause and user input?


# Trinity (only uses unpaired now..)
#Samples file is a list of samples and replicates for Trinity input
touch ./Aligner_Output/Trinity/samples.txt
for sample in ./SRA_Files/Raw_Files/*1.f*q.gz
do
    sampleName=`echo ${sample} | sed -e "s/^\.\/SRA_Files\/Raw_Files\///" -Ee "s/[12]u?\.f.*q\.gz$//"`
    for replicate in ./SRA_Files/Trimmed_Files/*${sampleName}*1.f*q.gz
    do
        fileType=`echo ${replicate} | egrep -o '\.f.*q\.gz'`
        replicateName=`echo ${replicate} | sed -e "s/^\.\/SRA_Files\/Trimmed_Files\///" -Ee "s/[12]u?\.f.*q\.gz$//"`
        echo -e "${sampleName}\t${replicateName}\t${replicateName}1${fileType}\t${replicateName}2${fileType}" >> ./Aligner_Output/Trinity/samples.txt
    done
done

trinity --seqType fq --max_memory 3G --samples_file ./Aligner_Output/Trinity/samples.txt --CPU 2 --min_contig_length 200 --no_normalize_reads --output ./Aligner_Output/Trinity/ --version



# rm -r ./temp/
