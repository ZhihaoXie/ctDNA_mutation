#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# FileName:  filter_vcf.py
# Author:    Zhihao Xie  \(#^o^)/
# Date:      2019\3\18 0018 14:16
# Version:   v1.0.0
# CopyRight: Copyright ©Zhihao Xie, All rights reserved.

import os, sys, re
import argparse

def get_parse():
    parser = argparse.ArgumentParser(description='filter vcf result of mutation')
    parser.add_argument('-d', dest='dp', default=10, type=int, help="Depth threshold value, default is %(default)s")
    parser.add_argument('-a', dest='ad', default=10, type=int, help="AD threshold value, default is %(default)s")
    #parser.add_argument('-f', dest='af_fold', default=2, type=int, help="Allele fractions fold, default is %(default)s")
    parser.add_argument('-v', dest='vcf', help="vcf file")
    options = parser.parse_args()
    if not options.vcf:
        parser.print_help()
        sys.exit()
    return options

def del_bad_allele(line, ad_filt=10):
    # delete allele type according to AD
    # 这里有一个不足处，没有对第8列进行数据更正
    rows = line.rstrip().split("\t")
    ref = rows[3]
    allele = rows[4].split(',')   # 原始的allele
    ref_allele = [ref]
    ref_allele.extend(allele)      # 原始的ref 和 allele，一个数组
    info_value = rows[9].split(":")
    info_index = rows[8].split(":")  # 索引列表
    info_values = dict(zip(info_index, info_value))  # 转化为字典
    ad_list = info_values.get('AD', '')
    if ad_list == "":
        sys.stderr.write("Error: not AD info. for: %s" % line)
        return ""
    else:
        ref_ad = ad_list.split(',')[0]
        ad_list = ad_list.split(',')[1:]
        allele_ad = dict(zip(allele, ad_list))
        allele_ad = {k:v for k,v in allele_ad.items() if int(v) >= ad_filt}  # 过滤差的AD
        if len(allele_ad) == 0:
            return ""
        else:
            # 构建新的allele INFO FORMAT
            GT = "/".join([str(x) for x in range(len(allele_ad) + 1)])
            allele_good, AD = zip(*sorted(allele_ad.items()))
            AD = list(AD)
            AD.insert(0, ref_ad)
            af_list = info_values.get('AF', '').split(",")
            allele_af = dict(zip(allele, af_list))
            allele_af = {k: allele_af[k] for k in allele_af if k in allele_ad}   # 过滤后的AF，一个字典
            _, AF = zip(*sorted(allele_af.items()))
            ref_allele_good = [ref]
            ref_allele_good.extend(allele_good)
            raw_F1R2 = info_values.get('F1R2', '').split(',')
            raw_F1R2_values = dict(zip(ref_allele, raw_F1R2))
            tmp_F1R2 = {k: raw_F1R2_values[k] for k in raw_F1R2_values if k in ref_allele_good}
            F1R2 = [tmp_F1R2[k] for k in allele_good]
            F1R2.insert(0, tmp_F1R2[ref])
            raw_F2R1 = info_values.get('F2R1', '').split(',')
            raw_F2R1_values = dict(zip(ref_allele, raw_F2R1))
            tmp_F2R1 = {k: raw_F2R1_values[k] for k in raw_F2R1_values if k in ref_allele_good}
            F2R1 = [tmp_F2R1[k] for k in allele_good]
            F2R1.insert(0, tmp_F2R1[ref])
            # 输出
            out_line = "\t".join(rows[:4]) + "\t" + ",".join(allele_good) + "\t" + "\t".join(rows[5:9]) + "\t"
            out_sample_info = []
            for k in info_index:
                if k == "GT":
                    out_sample_info.append(GT)
                elif k == 'AD':
                    out_sample_info.append(",".join(AD))
                elif k == "AF":
                    out_sample_info.append(",".join(AF))
                elif k == "F1R2":
                    out_sample_info.append(",".join(F1R2))
                elif k == "F2R1":
                    out_sample_info.append(",".join(F2R1))
                else:
                    out_sample_info.append(info_values.get(k, ""))
            out_sample_info = ":".join(out_sample_info)
            out_line += out_sample_info
            return out_line


def main():
    options = get_parse()
    vcf = os.path.abspath(options.vcf)
    dp = options.dp
    ad = options.ad
    #af_fold = options.af_fold

    with open(vcf) as ff:
        for line in ff:
            if re.match('##|#CHROM', line):
                print(line.rstrip("\n"))
                continue
            else:
                rows = line.rstrip().split("\t")
                s_dp = re.findall('DP=(\d+);?', rows[7])
                if len(s_dp) >= 1:
                    s_dp = int(s_dp[0])
                else:
                    s_dp = 0
                info_index = rows[8].split(":")
                info_value = rows[9].split(":")
                info_values = dict(zip(info_index, info_value))
                if s_dp == 0:
                    s_dp = info_values.get('DP', 0)
                s_ad = info_values.get('AD', '')
                s_ad = s_ad.split(',')  # 一个数组
                s_af = info_values.get('AF', '')
                s_af = s_af.split(',')
                # 判断dp
                if s_dp >= dp:
                    # 然后判断ad
                    if len(s_ad[1:]) == 1:
                        if int(s_ad[1]) >= ad:
                            print(line.rstrip("\n"))
                        else:
                            continue
                    elif len(s_ad[1:]) > 1:
                        vcf_line = del_bad_allele(line, ad)
                        print(vcf_line)
                else:
                    continue


if __name__ == '__main__':
    main()
