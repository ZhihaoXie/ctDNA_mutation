#!/bin/bash

bamFile=`readlink -f $1`
outdir=`readlink -f $2`
if [ ! -d $outdir ];then
    mkdir -p $outdir
fi
bam_basename=`basename $bamFile`
bam_basename=${bam_basename%.bam}

# picard
picard_dir="/home/xiezhihao/biosoft/picard-tools-2.18.21"
java="/usr/lib/jvm/java-8-openjdk-amd64/bin/java"

$java -Xmx2G -XX:MaxPermSize=512m -XX:-UseGCOverheadLimit -jar $picard_dir/picard.jar MarkDuplicates REMOVE_DUPLICATES=false I=$bamFile O=$outdir/${bam_basename}.dedup.bam M=$outdir/${bam_basename}.dup_metrics.txt TMP_DIR=$outdir/temp VALIDATION_STRINGENCY=LENIENT && \
    samtools index $outdir/${bam_basename}.dedup.bam

