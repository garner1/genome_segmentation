#!/usr/bin/env bash

in_dim=$1
out_dim=$2
datadir=$3
chr=$4

# echo "Parsing views ..."
# bash parse_views.sh /media/DS2415_seq/Genome_segmentation/views_"$chr"_"$in_dim"to"$out_dim"_LR.csv & pid1=$!
# bash parse_transitionMat.sh /media/DS2415_seq/Genome_segmentation/transitionMatrix_"$in_dim"to"$out_dim"_LR.csv & pid2=$!
# wait $pid1
# wait $pid2
# echo "Done"

# echo "Joining views and transition matrices to get the information profile ..."
# LC_ALL=C join -1 1 -2 3 -o 2.1 2.2 1.1 1.2 -t',' $datadir/transitionMatrix_"$in_dim"to"$out_dim"_LR.csv $datadir/views_"$chr"_"$in_dim"to"$out_dim"_LR.csv | 
# LC_ALL=C sort -t',' -k1,1n | tr ',' ' ' | 
# awk -v offset="$in_dim" '{print $1+offset,$4}' | LC_ALL=C sort -k1,1n > $datadir/input_to_peak__"$chr"_"$in_dim"to"$out_dim"_LR.csv
# echo "Done"

cat $datadir/input_to_peak__"$chr"_"$in_dim"to"$out_dim"_LR.csv | LC_ALL=C sort -k1,1 -o $datadir/input_to_peak__"$chr"_"$in_dim"to"$out_dim"_LR.csv
