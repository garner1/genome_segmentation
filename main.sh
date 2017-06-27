#!/usr/bin/env bash

# in_dim=6
# out_dim=3
datadir=~/Work/dataset/genome_segmentation
chr=chr21
threshold_on_conditionInformation=0.1

# echo 'First run the R-script which produces the relevant view (chromosomes, genes, etc) and the relevant markov chain parameters.'
# # Rscript get_kmer.R		
# # R < get_kmer.R --no-save  
# echo 'Done'

# for in_dim in 3 4 5 6
# do
#     out_dim=$((9-$in_dim))
#     bash ./preprocessing.sh $in_dim $out_dim $datadir $chr 
# done

# LC_ALL=C join $datadir/input_to_peak__chr21_3to6_LR.csv $datadir/input_to_peak__chr21_4to5_LR.csv | 
# LC_ALL=C join - $datadir/input_to_peak__chr21_5to4_LR.csv | 
# LC_ALL=C join - $datadir/input_to_peak__chr21_6to3_LR.csv | 
# awk '{print $1,$2/6+$3/5+$4/4+$5/3}' | LC_ALL=C sort -k1,1n > $datadir/joined_"$chr".csv # divide by the log(out_dim) to account for dim-scaling

# echo "Find local maxima in the information profile ..."
# python find_peaks.py $datadir/joined_"$chr".csv $datadir/plusStrand-forward__"$chr".csv $threshold_on_conditionInformation # find all extrema and threshold based on the condition_info value
# tail -n+2 $datadir/plusStrand-forward__chr21.csv | tr ',' ' '| cut -d' ' -f2- > $datadir/aux && mv $datadir/aux $datadir/plusStrand-forward__chr21.csv # parsing
# bash aggregate.sh $datadir/plusStrand-forward__chr21.csv $datadir/aux3.bed 3 $chr # cluster extrema closed than 3
# echo "Done d=3"
# bash aggregate.sh $datadir/aux3.bed $datadir/aux4.bed 4 $chr # cluster extrema closed than 4
# echo "Done d=4"
# bash aggregate.sh $datadir/aux4.bed $datadir/aux5.bed 5 $chr # cluster extrema closed than 5
# echo "Done d=5"
# bash aggregate.sh $datadir/aux5.bed $datadir/aux6.bed 6 $chr # cluster extrema closed than 6
# echo "Done d=6"
# bash aggregate.sh $datadir/aux6.bed $datadir/aux7.bed 7 $chr # cluster extrema closed than 7
# echo "Done d=7"
# bash aggregate.sh $datadir/aux7.bed $datadir/aux8.bed 8 $chr # cluster extrema closed than 8
# echo "Done d=8"
# bash aggregate.sh $datadir/aux8.bed $datadir/aux9.bed 9 $chr # cluster extrema closed than 9
# echo "Done d=9"
# cat $datadir/aux9.bed |
# awk -v chr="$chr" 'NR==1{start=$1;next}{OFS="\t";print chr,start,$1,"forward",$2,"+";start=$1}' > $datadir/word_forward__"$chr".bed 
# rm -f $datadir/aux?.bed
# echo "Done"

# echo "Make dictionary ..."
# bedtools getfasta -fi ~/igv/genomes/hg19.fasta -bed $datadir/word_forward__"$chr".bed -s -tab -fo $datadir/word_forward__"$chr".dic
# cat $datadir/word_forward__"$chr".dic | sed 's/(+)//' | tr ':-' '\t\t' | awk '{print $0"\t1\t+"}' > tmp.aux && mv tmp.aux $datadir/word_forward__"$chr".dic
# echo "Done"

# echo "Produce word-contect counts ..."
# echo "Create ordered word pairs (count how many times word1 is to the left of word2 inside a context window) within a context of size window ..."
# window=10
# python count_pairs.py $datadir/word_forward__"$chr".dic $window # file output is *_counter.txt
# cat $datadir/word_forward__"$chr".dic_counter.txt | tr -d '(',')',"'" | tr ' ' '\t' | LC_ALL=C grep -v N > $datadir/word_forward__"$chr".dic_counter.txt.aux && mv $datadir/word_forward__"$chr".dic_counter.txt.aux $datadir/word_forward__"$chr".dic_counter.txt
# echo "Done"

# echo "Prepare vocabulary: a 1to1 word-index map"
# cat $datadir/word_forward__"$chr".dic_counter.txt | cut -f-2 | tr '\t' '\n' | LC_ALL=C sort | LC_ALL=C uniq | cat -n | awk '{print $2,$1}' > $datadir/vocabulary
# echo "Done"

# echo "Associate matrix indeces to word-context pairs: the final .mat has word-context-count-row-col format"
# cat $datadir/word_forward__"$chr".dic_counter.txt| LC_ALL=C sort -k1,1 | LC_ALL=C join -1 1 -2 1 -o 1.1,1.2,1.3,2.2 - $datadir/vocabulary | tr ' ' '\t' |
# LC_ALL=C sort -k2,2 | LC_ALL=C join -1 2 -2 1 -o 1.1,1.2,1.3,1.4,2.2 - $datadir/vocabulary | tr ' ' '\t' > $datadir/word_forward__"$chr".dic_counter.txt.mat
# echo "Done"

# echo "Count the marginales of each word and context"
# cat $datadir/word_forward__"$chr".dic_counter.txt.mat |tr '.' ','|datamash -s -g 4 sum 3|tr ',' '.'|LC_ALL=C sort -n -k1,1 > $datadir/word_forward__"$chr".dic_counter.txt.mat.wordMarginale
# cat $datadir/word_forward__"$chr".dic_counter.txt.mat |tr '.' ','|datamash -s -g 5 sum 3|tr ',' '.'|LC_ALL=C sort -n -k1,1 > $datadir/word_forward__"$chr".dic_counter.txt.mat.contextMarginale
# echo "Done"

# echo "Prepare the sparse matrix in coo format: word-context-count-wordmarg-contextmarg-pmi"
# LC_ALL=C sort -n -k4,4 $datadir/word_forward__"$chr".dic_counter.txt.mat | LC_ALL=C join -o 1.4,1.5,1.3,2.2  -1 4 -2 1 - $datadir/word_forward__"$chr".dic_counter.txt.mat.wordMarginale | tr ' ' '\t' |
# LC_ALL=C sort -n -k2,2 - | LC_ALL=C join -o 1.1,1.2,1.3,1.4,2.2  -1 2 -2 1 - $datadir/word_forward__"$chr".dic_counter.txt.mat.contextMarginale | 
# awk '{print $1,$2,$3,$4,$5,$3/($4*$5)}' | tr ' ' '\t' > $datadir/word_forward__"$chr".dic_counter.txt.normalized.mat 
# D=`cat $datadir/word_forward__"$chr".dic_counter.txt.normalized.mat|wc -l`
# cat $datadir/word_forward__"$chr".dic_counter.txt.normalized.mat | awk -v D="$D" '{OFS="\t";print $1,$2,$3,$4,$5,$6*D}' > $datadir/"$chr".mat

# D=`cat $datadir/vocabulary|wc -l` # size of the vocabulary
# k=2				  # shift factor in SPPMI
# rank=3				  # truncation dim in svd
# python cooccurrence_matrix.py $datadir/"$chr".mat $D $k $rank
# echo "Done"

# mv $datadir/word_forward__"$chr".dic_counter.txt.mat $datadir/"$chr"_"$indim"to"$outdim"__word-context-counts-indexWord-indexContext.mat

# rm -f $datadir/vocabulary $datadir/*{joined,bed,csv,dic,txt,normalized*,contextMarginale,wordMarginale}

