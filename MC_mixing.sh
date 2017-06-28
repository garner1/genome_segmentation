#!/usr/bin/env bash

datadir=$1
chr=$2

for in_dim in 3 4 5 6		# consider only models whose input dimension is in between 3 and 6
do
    out_dim=$((9-$in_dim))

    echo "Parsing views ..."
    bash parse_views.sh /media/DS2415_seq/Genome_segmentation/views_"$chr"_"$in_dim"to"$out_dim"_LR.csv $datadir & pid1=$! # {start,end,sequence}
    bash parse_transitionMat.sh /media/DS2415_seq/Genome_segmentation/transitionMatrix_"$in_dim"to"$out_dim"_LR.csv $datadir & pid2=$! # {sequence,probability}
    wait $pid1
    wait $pid2
    echo "Done"

    echo "Joining views and transition matrices to get the information profile ..."
    LC_ALL=C join -1 1 -2 3 -o 2.1 2.2 1.1 1.2 -t',' $datadir/transitionMatrix_"$in_dim"to"$out_dim"_LR.csv $datadir/views_"$chr"_"$in_dim"to"$out_dim"_LR.csv | # {start,end,sequence,probability}
    LC_ALL=C sort -t',' -k1,1n | tr ',' ' ' | 
    awk -v offset="$in_dim" '{print $1+offset,$4}' | # {start+offset,probability}
    LC_ALL=C sort -k1,1 > $datadir/input_to_peak__"$chr"_"$in_dim"to"$out_dim"_LR.csv
    echo "Done"
done

LC_ALL=C join $datadir/input_to_peak__chr21_3to6_LR.csv $datadir/input_to_peak__chr21_4to5_LR.csv |
LC_ALL=C join - $datadir/input_to_peak__chr21_5to4_LR.csv | 
LC_ALL=C join - $datadir/input_to_peak__chr21_6to3_LR.csv | 
awk '{print $1,$2/6+$3/5+$4/4+$5/3}' | # {start,prob6/log(out_dim6)+prob5/log(out_dim5)+prob4/log(out_dim4)+prob3/log(out_dim3)}
LC_ALL=C sort -k1,1n > $datadir/joined_"$chr".csv # divide by the log(out_dim) to account for dim-scaling



