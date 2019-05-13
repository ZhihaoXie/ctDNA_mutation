#!/bin/bash

bamFile=`readlink -f $1`
bedFile=`readlink -f $2`
outdir=`readlink -f $3`

perl /home/zhongxin/Work/DNA_resequencing/TargetRegionSequencing/DNA_CSAP/pipeline/module/processBam/processBam_v1.0/bin/QC_exome.pl -i $bamFile -r $bedFile -o $outdir -s /home/zhongxin/Work/DNA_resequencing/TargetRegionSequencing/DNA_CSAP/pipeline/module/bin/samtools-0.1.18/samtools -plot
perl /home/zhongxin/Work/DNA_resequencing/TargetRegionSequencing/DNA_CSAP/pipeline/module/processBam/processBam_v1.0/bin/rate_for_picard.pl $bamFile /home/zhongxin/Work/DNA_resequencing/TargetRegionSequencing/DNA_CSAP/pipeline/module/bin/samtools-0.1.18/samtools >> $outdir/information.xls

