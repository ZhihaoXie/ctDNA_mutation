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
basename=${basename%.pre_analysis}

# ref and model
ref_genome="/home/xiezhihao/bioDatabase/Human/hg19/hg19.fa"
indels1="/home/xiezhihao/bioDatabase/Human/hg19/1000G_phase1.indels.hg19.sites.vcf"
indels2="/home/xiezhihao/bioDatabase/Human/hg19/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf"
dbsnp="/home/xiezhihao/bioDatabase/Human/hg19/dbsnp_138.hg19.vcf"
omni="/home/xiezhihao/bioDatabase/Human/hg19/1000G_omni2.5.hg19.sites.vcf"
hapmap="/home/xiezhihao/bioDatabase/Human/hg19/hapmap_3.3.hg19.sites.vcf"
g1000="/home/xiezhihao/bioDatabase/Human/hg19/1000G_phase1.snps.high_confidence.hg19.sites.vcf"

# run gatk4
gatk --java-options "-Xmx6g" HaplotypeCaller -R $ref_genome -I $bam_file -O $outdir/${basename}.g.vcf -ERC GVCF && \
    gatk --java-options "-Xmx4g" GenotypeGVCFs -R $ref_genome -V $outdir/${basename}.g.vcf -O $outdir/${basename}.raw.vcf && \
    gatk --java-options "-Xmx4g" VariantRecalibrator -R $ref_genome -V $outdir/${basename}.raw.vcf -O $outdir/${basename}.recal --resource hapmap,known=false,training=true,truth=true,prior=15.0:$hapmap --resource omni,known=false,training=true,truth=true,prior=12.0:$omni --resource 1000G,known=false,training=true,truth=false,prior=10.0:$g1000 --resource dbsnp,known=true,training=false,truth=false,prior=2.0:$dbsnp -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR --tranches-file $outdir/${basename}.tranches --mode SNP --rscript-file output.plots.R && \
    gatk --java-options "-Xmx4g" ApplyVQSR -R $ref_genome -V $outdir/${basename}.raw.vcf -O $outdir/${basename}.clean.vcf --recal-file $outdir/${basename}.recal --tranches-file $outdir/${basename}.tranches -ts-filter-level 99.0 --mode SNP

