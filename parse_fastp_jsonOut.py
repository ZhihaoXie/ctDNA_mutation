#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# FileName:  parse_fastp_jsonOut.py
# Author:    Zhihao Xie  \(#^o^)/
# Date:      2018\12\27 0027 9:59
# Version:   v1.0.0
# CopyRight: Copyright ©Zhihao Xie, All rights reserved.

import os, sys, re
import json

def format_2f(args):
    if isinstance(args, float):
        tmp = '{:.2f}'.format(args)
    elif isinstance(args, int):
        tmp = str(args)
    elif isinstance(args, str):
        tmp = args
    return tmp


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("usage: python3 {} json1 [json2] [...]".format(sys.argv[0]))
        sys.exit(1)

    # header
    print("SampleName\tRawReads\tRawBases(bp)\tCleanReads\tCleanBases(bp)\tCleanRate(%)\tCleanGC(%)\tQ20Fq1(%)\t"
          "Q20Fq2(%)\tQ30Fq1(%)\tQ30Fq2(%)\tGCFq1(%)\tGCFq2(%)")  # 13 item
    for myjson in sys.argv[1:]:
        if not os.path.isfile(myjson):
            continue

        basename = os.path.splitext(os.path.basename(myjson))[0]
        with open(myjson, 'r',encoding='utf-8') as f:
            load_f = json.load(f)
            raw_reads = load_f['summary']['before_filtering']['total_reads']
            raw_bases = load_f['summary']['before_filtering']['total_bases']
            clean_reads = load_f['summary']['after_filtering']['total_reads']
            clean_bases = load_f['summary']['after_filtering']['total_bases']
            clean_rate = clean_bases / raw_bases * 100
            clean_q20_rate = load_f['summary']['after_filtering']['q20_rate'] * 100
            clean_q30_rate = load_f['summary']['after_filtering']['q30_rate'] * 100
            clean_gc_percent = load_f['summary']['after_filtering']['gc_content'] * 100
            if 'read1_after_filtering' in load_f:
                fq1_q20_rate = (load_f['read1_after_filtering']['q20_bases']/load_f['read1_after_filtering']['total_bases'])*100
                fq1_q30_rate = (load_f['read1_after_filtering']['q30_bases']/load_f['read1_after_filtering']['total_bases'])*100
                fq1_gc_list = load_f['read1_after_filtering']['content_curves']['GC']
                fq1_gc_percent = sum(fq1_gc_list)/len(fq1_gc_list) * 100
            else:
                fq1_q20_rate = 'null'
                fq1_q30_rate = 'null'
                fq1_gc_percent = 'null'
            if 'read2_after_filtering' in load_f:
                fq2_q20_rate = (load_f['read2_after_filtering']['q20_bases']/load_f['read2_after_filtering']['total_bases'])*100
                fq2_q30_rate = (load_f['read2_after_filtering']['q30_bases']/load_f['read2_after_filtering']['total_bases'])*100
                fq2_gc_list = load_f['read2_after_filtering']['content_curves']['GC']
                fq2_gc_percent = sum(fq2_gc_list) / len(fq2_gc_list) * 100
            else:
                fq2_q20_rate = 'null'
                fq2_q30_rate = 'null'
                fq2_gc_percent = 'null'
            tmp_list = [basename, str(raw_reads), str(raw_bases), str(clean_reads), str(clean_bases), format_2f(clean_rate),
                        format_2f(clean_gc_percent), ]
            print("{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}".format(basename, raw_reads, raw_bases,
                        clean_reads, clean_bases, format_2f(clean_rate), format_2f(clean_gc_percent), format_2f(fq1_q20_rate),
                        format_2f(fq2_q20_rate), format_2f(fq1_q30_rate), format_2f(fq2_q30_rate), format_2f(fq1_gc_percent),
                                                                              format_2f(fq2_gc_percent)))
