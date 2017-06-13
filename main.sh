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
# python find_peaks.py ~/Work/dataset/genome_segmentation/views_chr21_3to1_LR.csv.joined ~/Work/dataset/genome_segmentation/word_forward.csv & pid1=$! 
# python find_peaks.py ~/Work/dataset/genome_segmentation/views_chr21_3to1_RL.csv.joined ~/Work/dataset/genome_segmentation/word_reverse.csv & pid2=$!
# wait $pid1
# wait $pid2
# echo "Done"

# echo "Generate the words' bed files ..."
# cut -d',' -f2 ~/Work/dataset/genome_segmentation/word_forward.csv | 
# grep -v position | 
# awk 'NR==1{start=$1;next}{OFS="\t";print "chr21",start,$1,"forward","1","+";start=$1}' > ~/Work/dataset/genome_segmentation/word_forward.bed & pid1=$!
# cut -d',' -f2 ~/Work/dataset/genome_segmentation/word_reverse.csv | 
# grep -v position | 
# awk 'NR==1{start=$1;next}{OFS="\t";print "chr21",start,$1,"reverse","1","-";start=$1}' > ~/Work/dataset/genome_segmentation/word_reverse.bed & pid2=$!
# wait $pid1
# wait $pid2
# echo "Done"

# echo "Make dictionary ..."
# bedtools getfasta -fi ~/igv/genomes/hg19.fasta -bed ~/Work/dataset/genome_segmentation/word_reverse.bed -s -tab -fo ~/Work/dataset/genome_segmentation/word_reverse.dic & pid1=$!
# bedtools getfasta -fi ~/igv/genomes/hg19.fasta -bed ~/Work/dataset/genome_segmentation/word_forward.bed -s -tab -fo ~/Work/dataset/genome_segmentation/word_forward.dic & pid2=$!
# wait $pid1
# wait $pid2
# cat ~/Work/dataset/genome_segmentation/word_reverse.dic | sed 's/(-)//' | tr ':-' '\t\t' | awk '{print $0"\t1\t-"}' > tmp1.aux && mv tmp1.aux ~/Work/dataset/genome_segmentation/word_reverse.dic & pid1=$!
# cat ~/Work/dataset/genome_segmentation/word_forward.dic | sed 's/(+)//' | tr ':-' '\t\t' | awk '{print $0"\t1\t+"}' > tmp2.aux && mv tmp2.aux ~/Work/dataset/genome_segmentation/word_forward.dic & pid2=$!
# wait $pid1
# wait $pid2
# echo "Done"

echo "Create word pairs with max distance of 1Kbp (this is memory intensive) ..."
cp ~/Work/dataset/genome_segmentation/word_reverse.dic ~/Work/dataset/genome_segmentation/word_reverse_copy.dic
cp ~/Work/dataset/genome_segmentation/word_forward.dic ~/Work/dataset/genome_segmentation/word_forward_copy.dic
bedtools window -a ~/Work/dataset/genome_segmentation/word_reverse.dic -b ~/Work/dataset/genome_segmentation/word_reverse_copy.dic -sm | awk '$8>$2' > ~/Work/dataset/genome_segmentation/wordPairs_reverse.dic & pid1=$!
bedtools window -a ~/Work/dataset/genome_segmentation/word_forward.dic -b ~/Work/dataset/genome_segmentation/word_forward_copy.dic -sm | awk '$8>$2' > ~/Work/dataset/genome_segmentation/wordPairs_forward.dic & pid2=$!
wait $pid1
wait $pid2
echo "Done"
