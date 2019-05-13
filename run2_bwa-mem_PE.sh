#!/bin/bash

if [ $# -lt 3 ];then
    echo "sh $0 <fq1> <fq2> 'SampleID'"
    exit 1
fi

fq1=`readlink -f $1`
fq2=`readlink -f $2`
sampleID=$3
ref_fasta=/home/xiezhihao/bioDatabase/Human/hg19/hg19.fa

bwa mem -t 4 -M -R "@RG\tID:$sampleID\tPL:Illumina\tPU:$sampleID\tLB:$sampleID\tSM:$sampleID" $ref_fasta $fq1 $fq2 |\
    samtools view -S -b - -o ${sampleID}.temp.bam && \
    samtools sort -m 2G ${sampleID}.temp.bam -o ${sampleID}.bam && \
    samtools index ${sampleID}.bam || exit 1

if [ -e ${sampleID}.bam -a -s ${sampleID}.bam ];then
    rm ${sampleID}.temp.bam
fi

