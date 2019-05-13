#!/bin/bash

if [ $# -lt 2 ];then
    echo "Usage: sh $0 <samplename> <vcf> [bed file]"
    exit 1
fi

samplename=$1
vcf_file=`readlink -f $2`
if [ $# -eq 3 ];then
    bed=`readlink -f $3`
else
    bed=""
fi

basename=$samplename

# reference
ref="/home/xiezhihao/bioDatabase/Human/hg19/hg19.fa"
#dbsnp="/home/xiezhihao/bioDatabase/Human/hg19/dbsnp_138.hg19.vcf"


if [ -e $vcf_file ];then
    vcf=$vcf_file
    gatk IndexFeatureFile -F $vcf
    if [ -n "$bed" ];then
        # SNP
        gatk SelectVariants -R $ref -V $vcf -O ${basename}.snp.vcf -select-type SNP -L $bed --max-fraction-filtered-genotypes 0.1 --max-nocall-fraction 0.01 && \
        gatk --java-options "-Xmx6g" VariantFiltration -V ${basename}.snp.vcf -O ${basename}.snp.filt.vcf -L $bed -R $ref --cluster-size 4 --cluster-window-size 10 --filter-name "lowQD" --filter-expression "QD < 2.0" --filter-name "lowMQ" --filter-expression "MQ < 30.0" --filter-name "highFS" --filter-expression "FS > 100.0" --filter-name "highSOR" --filter-expression "SOR > 6.0" --filter-name "lowMQRankSum" --filter-expression "MQRankSum < -12.5" --filter-name "lowReadPosRankSum" --filter-expression "ReadPosRankSum < -8.0" --filter-name "lowDP" --filter-expression "DP < 5.0" && \
        awk '{if($0~/#/){print} else if($7=="PASS"||$7=="."){print}}' ${basename}.snp.filt.vcf > ${basename}.snp.filt_pass.vcf && \
        rm ${basename}.snp.vcf*
        # INDEL
        gatk SelectVariants -R $ref -V $vcf -O ${basename}.indel.vcf -select-type INDEL -L $bed --max-fraction-filtered-genotypes 0.1 --max-nocall-fraction 0.001 && \
        gatk --java-options "-Xmx6g" VariantFiltration -V ${basename}.indel.vcf -O ${basename}.indel.filt.vcf -L $bed -R $ref --filter-name "lowQD" --filter-expression "QD < 2.0" --filter-name "highFS" --filter-expression "FS > 200.0" --filter-name "highSOR" --filter-expression "SOR > 15.0" --filter-name "lowReadPosRankSum" --filter-expression "ReadPosRankSum < -20.0" --filter-name "lowInbreedingCoeff" --filter-expression "InbreedingCoeff < -0.8" --filter-name "lowDP" --filter-expression "DP < 5.0" && \
        awk '{if($0~/#/){print} else if($7=="PASS"||$7=="."){print}}' ${basename}.indel.filt.vcf > ${basename}.indel.filt_pass.vcf && \
        rm ${basename}.indel.vcf*
    else
        # SNP
        gatk SelectVariants -R $ref -V $vcf -O ${basename}.snp.vcf -select-type SNP --max-fraction-filtered-genotypes 0.1 --max-nocall-fraction 0.001 && \
        gatk --java-options "-Xmx6g" VariantFiltration -V ${basename}.snp.vcf -O ${basename}.snp.filt.vcf -R $ref --cluster-size 4 --cluster-window-size 10 --filter-name "lowQD" --filter-expression "QD < 2.0" --filter-name "lowMQ" --filter-expression "MQ < 30.0" --filter-name "highFS" --filter-expression "FS > 100.0" --filter-name "highSOR" --filter-expression "SOR > 6.0" --filter-name "lowMQRankSum" --filter-expression "MQRankSum < -12.5" --filter-name "lowReadPosRankSum" --filter-expression "ReadPosRankSum < -8.0" --filter-name "lowDP" --filter-expression "DP < 5.0" && \
        awk '{if($0~/#/){print} else if($7=="PASS"||$7=="."){print}}' ${basename}.snp.filt.vcf > ${basename}.snp.filt_pass.vcf && \
        rm ${basename}.snp.vcf*
        # INDEL
        gatk SelectVariants -R $ref -V $vcf -O ${basename}.indel.vcf -select-type INDEL --max-fraction-filtered-genotypes 0.1 --max-nocall-fraction 0.001 && \
        gatk --java-options "-Xmx6g" VariantFiltration -V ${basename}.indel.vcf -O ${basename}.indel.filt.vcf -R $ref --filter-name "lowQD" --filter-expression "QD < 2.0" --filter-name "highFS" --filter-expression "FS > 200.0" --filter-name "highSOR" --filter-expression "SOR > 15.0" --filter-name "lowReadPosRankSum" --filter-expression "ReadPosRankSum < -20.0" --filter-name "lowInbreedingCoeff" --filter-expression "InbreedingCoeff < -0.8" --filter-name "lowDP" --filter-expression "DP < 5.0" && \
        awk '{if($0~/#/){print} else if($7=="PASS"||$7=="."){print}}' ${basename}.indel.filt.vcf > ${basename}.indel.filt_pass.vcf && \
        rm ${basename}.indel.vcf*
    fi
    gatk MergeVcfs -I ${basename}.snp.filt_pass.vcf -I ${basename}.indel.filt_pass.vcf -O ${basename}.snp_indel.vcf
else
    echo "Error: $vcf_file not found."
    exit 1
fi
