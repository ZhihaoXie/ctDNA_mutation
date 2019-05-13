#!/bin/bash

sampleID=$1
bam_file=`readlink -f $2`

mkdir ${sampleID}.bam.stats
samtools stats $bam_file > ${sampleID}.bam.stats/${sampleID}.bam.stats.txt && \
plot-bamstats -p ${sampleID}.bam.stats/${sampleID}.bam.stats.plot ${sampleID}.bam.stats/${sampleID}.bam.stats.txt
samtools flagstat $bam_file > ${sampleID}.bam.stats/${sampleID}.bam.flagstat.txt
