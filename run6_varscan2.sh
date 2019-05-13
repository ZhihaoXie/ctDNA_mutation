#!/bin/bash

samtools mpileup -B -Q 20 -C 50 -q 20 -d 20000 -f ~/bioDatabase/Human/hg19/hg19.fa -l tengfei_panel_bed_hg19.bed LucCF1712054-KY.pre_analysis.bam > LucCF1712054-KY.mpileup
# SNP calling with VarScan
java -jar ~/biosoft/VarScan2/VarScan.v2.4.2.jar mpileup2snp LucCF1712054-KY.mpileup --min-coverage 4 --min-reads2 2 --min-avg-qual 20 --min-var-freq 0.001 --min-freq-for-hom 90 --output-vcf 1 > LucCF1712054-KY.varscan.snp.vcf
# INDEL calling with VarScan
java -jar ~/biosoft/VarScan2/VarScan.v2.4.2.jar mpileup2indel LucCF1712054-KY.mpileup --min-coverage 4 --min-reads2 2 --min-avg-qual 20 --min-var-freq 0.001 --min-freq-for-hom 90 --output-vcf 1 > LucCF1712054-KY.varscan.indel.vcf

