#!/bin/bash
# require GATK4

if [ $# -lt 2 ];then
    echo "Usage: sh $0 <bam> <outdir>"
    exit
fi

bam_file=`readlink -f $1`
outdir=`readlink -f $2`
if [ ! -d $outdir ];then
    mkdir -p $outdir
fi

basename=`basename $bam_file`
basename=${basename%.bam}

# ref
ref_genome="/home/xiezhihao/bioDatabase/Human/hg19/hg19.fa"
indels1="/home/xiezhihao/bioDatabase/Human/hg19/1000G_phase1.indels.hg19.sites.vcf"
indels2="/home/xiezhihao/bioDatabase/Human/hg19/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf"
dbsnp="/home/xiezhihao/bioDatabase/Human/hg19/dbsnp_138.hg19.vcf"

# run gatk4
gatk --java-options "-Xmx6G -Djava.io.tmpdir=./" BaseRecalibrator -I $bam_file -O $outdir/${basename}.recal_data.table -R $ref_genome --known-sites $dbsnp --known-sites $indels1 --known-sites $indels2 --bqsr-baq-gap-open-penalty 30 && \
gatk --java-options "-Xmx6G -Djava.io.tmpdir=./" ApplyBQSR -I $bam_file -O $outdir/${basename}.pre_analysis.bam -bqsr $outdir/${basename}.recal_data.table -R $ref_genome

