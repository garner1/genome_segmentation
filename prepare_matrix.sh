#!/usr/bin/env bash

datadir=$1
chr=$2

cat $datadir/segmented__"$chr".dic_counter.txt | 
LC_ALL=C sort -k1,1 | LC_ALL=C join -1 1 -2 1 -o 1.1,1.2,1.3,2.2 - $datadir/vocabulary | tr ' ' '\t' |
LC_ALL=C sort -k2,2 | LC_ALL=C join -1 2 -2 1 -o 1.1,1.2,1.3,1.4,2.2 - $datadir/vocabulary | 
tr ' ' '\t' > $datadir/segmented__"$chr".dic_counter.txt.mat

echo "Count the marginales of each word and context"
cat $datadir/segmented__"$chr".dic_counter.txt.mat |tr '.' ','|datamash -s -g 4 sum 3|tr ',' '.'|LC_ALL=C sort -n -k1,1 > $datadir/segmented__"$chr".dic_counter.txt.mat.wordMarginale
cat $datadir/segmented__"$chr".dic_counter.txt.mat |tr '.' ','|datamash -s -g 5 sum 3|tr ',' '.'|LC_ALL=C sort -n -k1,1 > $datadir/segmented__"$chr".dic_counter.txt.mat.contextMarginale
echo "Done"

echo "Prepare the sparse matrix in coo format: word-context-count-wordmarg-contextmarg-pmi"
LC_ALL=C sort -n -k4,4 $datadir/segmented__"$chr".dic_counter.txt.mat | 
LC_ALL=C join -o 1.4,1.5,1.3,2.2  -1 4 -2 1 - $datadir/segmented__"$chr".dic_counter.txt.mat.wordMarginale | tr ' ' '\t' |
LC_ALL=C sort -n -k2,2 - | 
LC_ALL=C join -o 1.1,1.2,1.3,1.4,2.2  -1 2 -2 1 - $datadir/segmented__"$chr".dic_counter.txt.mat.contextMarginale | 
awk '{print $1,$2,$3,$4,$5}' | tr ' ' '\t' > $datadir/"$chr".mat

cp $datadir/segmented__"$chr".dic_counter.txt.mat $datadir/"$chr"_"$indim"to"$outdim"__word-context-counts-indexWord-indexContext.mat
