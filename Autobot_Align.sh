#!/bin/bash

# Program path variables:
trinity=/opt/trinityrnaseq*/Trinity



#Trinity
Trinity_CPUs=`grep -c processor /proc/cpuinfo`
Trinity_max_memory=`free -g | awk 'FNR == 2 {print $4}'`


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
        echo -e "${sampleName}\t${replicateName}\t./SRA_Files/Trimmed_Files/${replicateName}1${fileType}\t./SRA_Files/Trimmed_Files/${replicateName}2${fileType}" >> ./Aligner_Output/Trinity/samples.txt
    done
done

#trinity --seqType fq --max_memory ${Trinity_max_memory}G --samples_file ./Aligner_Output/Trinity/samples.txt --CPU ${Trinity_CPUs} --min_contig_length 200 --no_normalize_reads --output ./Aligner_Output/Trinity/

