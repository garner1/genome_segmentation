#!/usr/bin/env bash

datadir=$1
chr=$2

cat $datadir/segmented__"$chr".dic_counter.txt | cut -f-2 | tr '\t' '\n' | LC_ALL=C sort | LC_ALL=C uniq | cat -n | awk '{print $2,$1}' > $datadir/vocabulary
