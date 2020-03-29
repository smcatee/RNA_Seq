#!/bin/bash



# Program path variables:
fastqc=/opt/FastQC/fastqc
trimmomatic=/opt/Trimmomatic-0.39/trimmomatic-0.39.jar
solexaqa=/opt/Linux_x64/SolexaQA++



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
