#!/usr/bin/env bash

in_dim=3
out_dim=1

# First run the R-script
# Rscript get_kmer.R		
R < get_kmer.R --no-save  

# parallel bash parse_views.sh {} ::: /home/garner1/Work/dataset/genome_segmentation/views_chr{?,??}_"$in_dim"to"$out_dim"_{LR,RL}.csv
# parallel bash parse_views.sh {} ::: /home/garner1/Work/dataset/genome_segmentation/views_chr1_"$in_dim"to"$out_dim"_{LR,RL}.csv

# parallel bash parse_transitionMat.sh {} ::: /home/garner1/Work/dataset/genome_segmentation/transitionMatrix_"$in_dim"to"$out_dim"_{LR,RL}.csv

# parallel "rm -f ~/joined_{}; LC_ALL=C join -1 1 -2 3 -o 2.1 2.2 1.1 1.2 -t',' /home/garner1/Work/dataset/genome_segmentation/transitionMatrix_'\$in_dim'to'\$out_dim'_LR.csv {} | LC_ALL=C sort -t',' -k1,1n -o {.}joined" ::: `ls /home/garner1/Work/dataset/genome_segmentation/views_chr{?,??}_"$in_dim"to"$out_dim"_LR.csv`

# parallel "rm -f ~/joined_{}; LC_ALL=C join -1 1 -2 3 -o 2.1 2.2 1.1 1.2 -t',' /home/garner1/Work/dataset/genome_segmentation/transitionMatrix_'\$in_dim'to'\$out_dim'_RL.csv {} | LC_ALL=C sort -t',' -k1,1n -o {.}joined" ::: `ls /home/garner1/Work/dataset/genome_segmentation/views_chr{?,??}_"$in_dim"to"$out_dim"_RL.csv`

