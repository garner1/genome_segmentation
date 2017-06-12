#!/usr/bin/env bash

# in_dim=3
# out_dim=1

# # First run the R-script
# # Rscript get_kmer.R		
# # R < get_kmer.R --no-save  

# echo "Parsing views ..."
# # parallel bash parse_views.sh {} ::: /home/garner1/Work/dataset/genome_segmentation/views_chr{?,??}_"$in_dim"to"$out_dim"_{LR,RL}.csv
# parallel bash parse_views.sh {} ::: /home/garner1/Work/dataset/genome_segmentation/views_chr21_"$in_dim"to"$out_dim"_{LR,RL}.csv

# parallel bash parse_transitionMat.sh {} ::: /home/garner1/Work/dataset/genome_segmentation/transitionMatrix_"$in_dim"to"$out_dim"_{LR,RL}.csv
# echo "Done"

# echo "Joining views and transition matrices ..."
# # parallel "rm -f ~/joined_{}; LC_ALL=C join -1 1 -2 3 -o 2.1 2.2 1.1 1.2 -t',' /home/garner1/Work/dataset/genome_segmentation/transitionMatrix_'\$in_dim'to'\$out_dim'_LR.csv {} | LC_ALL=C sort -t',' -k1,1n -o {.}joined" ::: `ls /home/garner1/Work/dataset/genome_segmentation/views_chr{?,??}_"$in_dim"to"$out_dim"_LR.csv`
# # parallel "rm -f ~/joined_{}; LC_ALL=C join -1 1 -2 3 -o 2.1 2.2 1.1 1.2 -t',' /home/garner1/Work/dataset/genome_segmentation/transitionMatrix_'\$in_dim'to'\$out_dim'_RL.csv {} | LC_ALL=C sort -t',' -k1,1n -o {.}joined" ::: `ls /home/garner1/Work/dataset/genome_segmentation/views_chr{?,??}_"$in_dim"to"$out_dim"_RL.csv`
# LC_ALL=C join -1 1 -2 3 -o 2.1 2.2 1.1 1.2 -t',' /home/garner1/Work/dataset/genome_segmentation/transitionMatrix_"$in_dim"to"$out_dim"_LR.csv /home/garner1/Work/dataset/genome_segmentation/views_chr21_"$in_dim"to"$out_dim"_LR.csv | LC_ALL=C sort -t',' -k1,1n -o /home/garner1/Work/dataset/genome_segmentation/views_chr21_"$in_dim"to"$out_dim"_LR.csv.joined
# LC_ALL=C join -1 1 -2 3 -o 2.1 2.2 1.1 1.2 -t',' /home/garner1/Work/dataset/genome_segmentation/transitionMatrix_"$in_dim"to"$out_dim"_RL.csv /home/garner1/Work/dataset/genome_segmentation/views_chr21_"$in_dim"to"$out_dim"_LR.csv | LC_ALL=C sort -t',' -k1,1n -o /home/garner1/Work/dataset/genome_segmentation/views_chr21_"$in_dim"to"$out_dim"_RL.csv.joined

# echo "Done"

# echo "Find local maxima in information ..."
# python find_peaks.py ~/Work/dataset/genome_segmentation/views_chr21_3to1_LR.csv.joined ~/Work/dataset/genome_segmentation/word_start.csv & pid1=$! 
# python find_peaks.py ~/Work/dataset/genome_segmentation/views_chr21_3to1_RL.csv.joined ~/Work/dataset/genome_segmentation/word_end.csv & pid2=$!
# wait $pid1
# wait $pid2
# echo "Done"

# echo "Generate the words' bed files ..."
# cut -d',' -f2 ~/Work/dataset/genome_segmentation/word_start.csv | grep -v position | awk 'NR==1{start=$1;next}{OFS="\t";print "chr21",start,$1;start=$1}' > ~/Work/dataset/genome_segmentation/word_start.bed & pid1=$!
# cut -d',' -f2 ~/Work/dataset/genome_segmentation/word_end.csv | grep -v position | awk 'NR==1{start=$1;next}{OFS="\t";print "chr21",start,$1;start=$1}' > ~/Work/dataset/genome_segmentation/word_end.bed & pid2=$!
# wait $pid1
# wait $pid2
# echo "Done"

echo "Make dictionary ..."
bedtools getfasta -fi ~/igv/genomes/hg19.fasta -bed ~/Work/dataset/genome_segmentation/word_end.bed -fo ~/Work/dataset/genome_segmentation/word_end.dic & pid1=$!
bedtools getfasta -fi ~/igv/genomes/hg19.fasta -bed ~/Work/dataset/genome_segmentation/word_start.bed -fo ~/Work/dataset/genome_segmentation/word_start.dic & pid2=$!
wait $pid1
wait $pid2
echo "Done"
