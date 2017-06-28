#!/usr/bin/env bash

datadir=$1
chr=$2

bedtools getfasta -fi ~/igv/genomes/hg19.fasta -bed $datadir/segmented__"$chr".bed -s -tab -fo $datadir/segmented__"$chr".dic

cat $datadir/segmented__"$chr".dic | sed 's/(+)//' | tr ':-' '\t\t' | awk '{print $0"\t1\t+"}' > tmp.aux && mv tmp.aux $datadir/segmented__"$chr".dic


