#!/bin/bash

vcf=`readlink -f $1`
outprefix=$2

# annovar
annovar_dir="/home/xiezhihao/biosoft/annovar"

perl $annovar_dir/table_annovar.pl $vcf $annovar_dir/humandb/ -buildver hg19 -out $outprefix -remove -protocol refGene,cytoBand,cosmic70,snp138,clinvar_20180603,1000g2015aug_all,esp6500siv2_all,dbscsnv11,dbnsfp35c -operation g,r,f,f,f,f,f,f,f -nastring . -vcfinput

