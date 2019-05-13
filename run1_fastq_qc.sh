#!/bin/bash

if [ $# -lt 3 ];then
    echo "Usage: sh $0 <fq1> [fq2] <outdir> <sampleName>"
    exit 1
fi

if [ $# -eq 4 ];then
    fq1=`readlink -f $1`
    fq2=`readlink -f $2`
    outdir=`readlink -f $3`
    sample=$4
    single='no'
elif [ $# -eq 3 ];then
    fq1=`readlink -f $1`
    outdir=`readlink -f $2`
    sample=$3
    single='yes'
fi

# binary
fastp='/home/xiezhihao/biosoft/fastp/fastp'

if [ ! -d $outdir ];then
    mkdir -p $outdir
fi
cd $outdir
if [ $single = 'no' ];then
    $fastp -i $fq1 -o ${sample}.R1.fastq.gz -I $fq2 -O ${sample}.R2.fastq.gz --detect_adapter_for_pe -l 35 -q 20 -u 50 -n 15 -W 4 -j ${sample}.json -h ${sample}.html
elif [ $single = 'yes' ];then
    $fastp -i $fq1 -o ${sample}.clean.fastq.gz -l 35 -q 20 -u 50 -n 15 -W 4 -j ${sample}.json -h ${sample}.html
fi

