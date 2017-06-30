#!/usr/bin/env bash

window=$1
datadir=$2
chr=$3

window=10

python count_pairs.py $datadir/segmented__"$chr".dic $window # file output is *_counter.txt

cat $datadir/segmented__"$chr".dic_counter.txt | tr -d '(',')',"'" | tr ' ' '\t' | 
LC_ALL=C grep -v N > $datadir/segmented__"$chr".dic_counter.txt.aux && mv $datadir/segmented__"$chr".dic_counter.txt.aux $datadir/segmented__"$chr".dic_counter.txt & pid1=$!

cat $datadir/segmented__"$chr".dic_weight.txt | tr -d '(',')',"'" | tr ' ' '\t' | 
LC_ALL=C grep -v N > $datadir/segmented__"$chr".dic_weight.txt.aux && mv $datadir/segmented__"$chr".dic_weight.txt.aux $datadir/segmented__"$chr".dic_weight.txt & pid2=$!

wait $pid1
wait $pid2

echo "Pair word-context counts and weights"
LC_ALL=C join -j1 -o1.2,1.3,1.4,2.4 <(<$datadir/segmented__$chr.dic_weight.txt awk '{print $1"-"$2" "$0}' | 
LC_ALL=C sort -k1,1) <(<$datadir/segmented__$chr.dic_counter.txt awk '{print $1"-"$2" "$0}' | LC_ALL=C sort -k1,1) > $datadir/paired_count-weight.txt
echo "Done"
