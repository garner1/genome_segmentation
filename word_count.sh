#!/usr/bin/env bash

window=$1
datadir=$2
chr=$3

window=10

python count_pairs.py $datadir/segmented__"$chr".dic $window # file output is *_counter.txt

cat $datadir/segmented__"$chr".dic_counter.txt | tr -d '(',')',"'" | tr ' ' '\t' | 
LC_ALL=C grep -v N > $datadir/segmented__"$chr".dic_counter.txt.aux && mv $datadir/segmented__"$chr".dic_counter.txt.aux $datadir/segmented__"$chr".dic_counter.txt
