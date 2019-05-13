#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# FileName:  mapped_stats4bedFile.py
# Author:    Zhihao Xie  \(#^o^)/
# Date:      2018\12\26 0026 16:51
# Version:   v1.0.0
# CopyRight: Copyright ©Zhihao Xie, All rights reserved.

import os, sys, re
import subprocess
import argparse

def get_args():
    parser = argparse.ArgumentParser(description="alignment mapped stats of bed file for TRS")
    parser.add_argument('-m', dest='bam', help='bam file')
    parser.add_argument('-b', dest='bed', help='bed file')
    parser.add_argument('-n', dest='sample', help='sample name as output prefix')
    parser.add_argument('-s', dest='samtools', default='/opt/biosoft/samtools-1.9/bin/samtools', help=''
                                                        'samtools binary')
    args = parser.parse_args()
    if not args.bam or not args.bed:
        parser.print_help()
        sys.exit(1)
    return args

def get_samtools_stats(bamStatsFile):
    # get infos from samtools stats result
    status, outstring = subprocess.getstatusoutput('cat {} |grep ^SN | cut -f 2-'.format(bamStatsFile))
    if status == 0:
        outstring = outstring.split('\n')
        reads_mapped = 0
        bases_mapped = 0
        mismatches = 0
        target_bases = 0
        for line in outstring:
            if re.search('^reads mapped:', line):
                m = re.match('reads mapped:\s*(\d+)', line)
                if m:
                    reads_mapped = int(m.group(1))
            elif re.search('^bases mapped \(cigar\):', line):
                m = re.match('bases mapped \(cigar\):\s*(\d+)', line)
                if m:
                    bases_mapped = int(m.group(1))
            elif re.search('^mismatches:', line):
                m = re.match('mismatches:\s*(\d+)', line)
                if m:
                    mismatches = int(m.group(1))
            elif re.search('^bases inside the target:', line):
                m = re.match('bases inside the target:\s(\d+)', line)
                if m:
                    target_bases = int(m.group(1))
        if bases_mapped != 0:
            right_rate = (1 - (mismatches/bases_mapped)) * 100
        else:
            right_rate = 0
        return (reads_mapped, bases_mapped, right_rate, target_bases)
    else:
        sys.exit("Error: read {} file failed.".format(bamStatsFile))

## main
if __name__ == "__main__":
    args = get_args()
    bamFile = os.path.abspath(args.bam)
    bedFile = os.path.abspath(args.bed)
    name = args.sample
    samtools = args.samtools

    # for all
    temp_file = name + '.noBed_stats.txt'
    status = os.system('{} stats {} > {}'.format(samtools, bamFile, temp_file))
    if status == 0:
        reads_mapped, bases_mapped, right_rate, target_bases = get_samtools_stats(temp_file)
    else:
        sys.exit("Error: samtools stats failed.\n")

    # for target region
    temp_file = name + '.onlyBed_stats.txt'
    status = os.system("{s} stats -t {bed} {bam} > {out}".format(s=samtools, bed=bedFile, bam=bamFile, out=temp_file))
    if status == 0:
        target_reads_mapped, target_bases_mapped, target_right_rate, bed_target_bases = get_samtools_stats(temp_file)
    else:
        sys.exit("Error: samtools stats for bed failed.\n")

    target_reads_rate = (target_reads_mapped / reads_mapped * 100) if reads_mapped != 0 else 0
    target_bases_rate = (target_bases_mapped / bases_mapped * 100) if bases_mapped != 0 else 0
    target_depth = (target_bases_mapped / bed_target_bases) if bed_target_bases != 0 else 0

    # depth for every bases
    temp_file = name + '.baseDepth.txt'
    status = os.system('{s} depth -b {bed} {bam} > {out}'.format(s=samtools, bed=bedFile, bam=bamFile, out=temp_file))
    if status == 0:
        s, ss = subprocess.getstatusoutput(r"awk -F '\t' '$3>=1{a+=1};$3>=10{a10+=1};$3>=20{a20+=1};$3>=50{a50+=1}END{print a/%s*100,a10/%s*100,a20/%s*100,a50/%s*100}' %s" % (
            bed_target_bases, bed_target_bases, bed_target_bases, bed_target_bases, temp_file
        ))
        if s == 0:
            ss = ss.strip().split(" ")
            ss = [float(x) for x in ss]
    else:
        sys.exit("Error: samtools depth failed.\n")

    with open(name+'.mapped_stats.txt', 'w') as outf:
        outf.write("质控指标\t检测值\n")
        outf.write("与人基因组匹配的reads片段数\t{}\n".format(reads_mapped))
        outf.write("与目标区域匹配的reads片段数\t{}\n".format(target_reads_mapped))
        outf.write("与目标区域匹配的reads片段数占与人基因组匹配的reads片段数比例\t{:.2f}%\n".format(target_reads_rate))
        outf.write("与人基因组匹配的reads总碱基数（bp）\t{}\n".format(bases_mapped))
        outf.write("与目标区域匹配的reads总碱基数（bp）\t{}\n".format(target_bases_mapped))
        outf.write("与目标区域匹配的reads碱基数占与人基因组匹配的reads碱基数比例\t{:.2f}%\n".format(target_bases_rate))
        outf.write("目标区域的碱基数（bp）\t{}\n".format(bed_target_bases))
        outf.write("碱基平均覆盖深度\t{:.0f}\n".format(target_depth))
        outf.write("目标区域碱基覆盖度的一致率\t{:.2f}%\n".format(target_right_rate))
        outf.write("目标区域覆盖深度1X以上碱基数比上占比\t{:.2f}%\n".format(ss[0]))
        outf.write("目标区域覆盖深度10X以上碱基数比上占比\t{:.2f}%\n".format(ss[1]))
        outf.write("目标区域覆盖深度20X以上碱基数比上占比\t{:.2f}%\n".format(ss[2]))
        outf.write("目标区域覆盖深度50X以上碱基数比上占比\t{:.2f}%\n".format(ss[3]))

    
