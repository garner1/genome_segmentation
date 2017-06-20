#!/usr/bin/env bash

# in_dim=6
# out_dim=3
datadir=~/Work/dataset/genome_segmentation
chr=chr21

# echo 'First run the R-script which produces the relevant view (chromosomes, genes, etc) and the relevant markov chain parameters.'
# # Rscript get_kmer.R		
# # R < get_kmer.R --no-save  
# echo 'Done'

# for in_dim in 3 4 5 6 7 8
# do
#     out_dim=$((9-$in_dim))
#     bash ./preprocessing.sh $in_dim $out_dim $datadir $chr 
# done

# LC_ALL=C join $datadir/input_to_peak__chr21_3to6_LR.csv $datadir/input_to_peak__chr21_4to5_LR.csv | 
# LC_ALL=C join - $datadir/input_to_peak__chr21_5to4_LR.csv | 
# LC_ALL=C join - $datadir/input_to_peak__chr21_6to3_LR.csv | 
# awk '{print $1,$2/6+$3/5+$4/4+$5/3}' | LC_ALL=C sort -k1,1n > $datadir/joined_"$chr".csv # divide by the log(out_dim) to account for dim-scaling

# echo "Find local maxima in the information profile ..."
# python find_peaks.py $datadir/joined_"$chr".csv $datadir/plusStrand-forward__"$chr".csv
# echo "Done"

# echo "Generate the words' bed files after removing close local maxima..."
# tail -n+2 $datadir/plusStrand-forward__chr21.csv | tr ',' ' ' |
# awk 'NR==1{print $2,$3;pos=$2;max=$3;next}{print $2,$3,$2-pos,$3-max;pos=$2;max=$3}' | awk '$3!=2 || $4>0' | # filter out close maxima
# awk 'NR==1{pos=$1;max=$2;next}$3<3{pos=$1;max=$2}$3>2{print pos;pos=$1;max=$2}' |
# awk -v chr="$chr" 'NR==1{start=$1;next}{OFS="\t";print chr,start,$1,"forward","1","+";start=$1}' > $datadir/word_forward__"$chr".bed
# echo 'Done'

# echo "Make dictionary ..."
# bedtools getfasta -fi ~/igv/genomes/hg19.fasta -bed $datadir/word_forward__"$chr".bed -s -tab -fo $datadir/word_forward__"$chr".dic
# cat $datadir/word_forward__"$chr".dic | sed 's/(+)//' | tr ':-' '\t\t' | awk '{print $0"\t1\t+"}' > tmp.aux && mv tmp.aux $datadir/word_forward__"$chr".dic
# echo "Done"

echo "Produce word-contect counts ..."
echo "Create ordered word pairs (count how many times word1 is to the left of word2 inside a context window) within a context of size window ..."
window=10
python count_pairs.py $datadir/word_forward__"$chr".dic $window # file output is *_counter.txt
cat $datadir/word_forward__"$chr".dic_counter.txt | tr -d '(',')',"'" | tr ' ' '\t' | LC_ALL=C grep -v N > $datadir/word_forward__"$chr".dic_counter.txt.aux && mv $datadir/word_forward__"$chr".dic_counter.txt.aux $datadir/word_forward__"$chr".dic_counter.txt
echo "Done"

echo "Prepare vocabulary: a 1to1 word-index map"
cat $datadir/word_forward__"$chr".dic_counter.txt | cut -f-2 | tr '\t' '\n' | LC_ALL=C sort | LC_ALL=C uniq | cat -n | awk '{print $2,$1}' > $datadir/vocabulary
echo "Done"

echo "Associate matrix indeces to word-context pairs: the final .mat has word-context-count-row-col format"
cat $datadir/word_forward__"$chr".dic_counter.txt| LC_ALL=C sort -k1,1 | LC_ALL=C join -1 1 -2 1 -o 1.1,1.2,1.3,2.2 - $datadir/vocabulary | tr ' ' '\t' |
LC_ALL=C sort -k2,2 | LC_ALL=C join -1 2 -2 1 -o 1.1,1.2,1.3,1.4,2.2 - $datadir/vocabulary | tr ' ' '\t' > $datadir/word_forward__"$chr".dic_counter.txt.mat
echo "Done"

echo "Count the marginales of each word and context"
cat $datadir/word_forward__"$chr".dic_counter.txt.mat | datamash -s -g 4 sum 3|LC_ALL=C sort -n -k1,1 > $datadir/word_forward__"$chr".dic_counter.txt.mat.wordMarginale
cat $datadir/word_forward__"$chr".dic_counter.txt.mat | datamash -s -g 5 sum 3|LC_ALL=C sort -n -k1,1 > $datadir/word_forward__"$chr".dic_counter.txt.mat.contextMarginale
echo "Done"

echo "Prepare the sparse matrix in coo format: word-context-count-wordmarg-contextmarg-pmi"
LC_ALL=C sort -n -k4,4 $datadir/word_forward__"$chr".dic_counter.txt.mat | LC_ALL=C join -o 1.4,1.5,1.3,2.2  -1 4 -2 1 - $datadir/word_forward__"$chr".dic_counter.txt.mat.wordMarginale | tr ' ' '\t' |
LC_ALL=C sort -n -k2,2 - | LC_ALL=C join -o 1.1,1.2,1.3,1.4,2.2  -1 2 -2 1 - $datadir/word_forward__"$chr".dic_counter.txt.mat.contextMarginale | 
awk '{print $1,$2,$3,$4,$5,$3/($4*$5)}' | tr ' ' '\t' > $datadir/word_forward__"$chr".dic_counter.txt.normalized.mat 
D=`cat $datadir/word_forward__"$chr".dic_counter.txt.normalized.mat|wc -l`
cat $datadir/word_forward__"$chr".dic_counter.txt.normalized.mat | awk -v D="$D" '{OFS="\t";print $1,$2,$3,$4,$5,$6*D}' > $datadir/"$chr".mat

D=`cat $datadir/vocabulary|wc -l` # size of the vocabulary
k=2				  # shift factor in SPPMI
rank=3				  # truncation dim in svd
python cooccurrence_matrix.py $datadir/"$chr".mat $D $k $rank
echo "Done"

# mv $datadir/word_forward__"$chr".dic_counter.txt.mat $datadir/"$chr"_"$indim"to"$outdim"__word-context-counts-indexWord-indexContext.mat
# rm -f $datadir/vocabulary $datadir/*{joined,bed,csv,dic,txt,normalized*,contextMarginale,wordMarginale}

######################################
######################################
# # # parallel bash parse_views.sh {} ::: $datadir/views_chr{?,??}_"$in_dim"to"$out_dim"_{LR,RL}.csv

# # parallel "rm -f ~/joined_{}; LC_ALL=C join -1 1 -2 3 -o 2.1 2.2 1.1 1.2 -t',' $datadir/transitionMatrix_'\$in_dim'to'\$out_dim'_LR.csv {} | LC_ALL=C sort -t',' -k1,1n -o {.}joined" ::: `ls $datadir/views_chr{?,??}_"$in_dim"to"$out_dim"_LR.csv`
# # parallel "rm -f ~/joined_{}; LC_ALL=C join -1 1 -2 3 -o 2.1 2.2 1.1 1.2 -t',' $datadir/transitionMatrix_'\$in_dim'to'\$out_dim'_RL.csv {} | LC_ALL=C sort -t',' -k1,1n -o {.}joined" ::: `ls $datadir/views_chr{?,??}_"$in_dim"to"$out_dim"_RL.csv`

# echo "Create word pairs with max distance of 1Kbp (this is memory intensive) ..."
# cp $datadir/word_reverse.dic $datadir/word_reverse_copy.dic
# cp $datadir/word_forward__"$chr".dic $datadir/word_forward__"$chr"_copy.dic
# bedtools window -a $datadir/word_reverse.dic -b $datadir/word_reverse_copy.dic -sm | awk '$8>$2' > $datadir/wordPairs_reverse_"$in_dim"to"$out_dim".dic & pid1=$!
# bedtools window -a $datadir/word_forward__"$chr".dic -b $datadir/word_forward__"$chr"_copy.dic -sm | awk '$8>$2' > $datadir/wordPairs_forward_"$in_dim"to"$out_dim".dic & pid2=$!
# wait $pid1
# wait $pid2
# rm -f $datadir/word_*_copy.dic
# echo "Done"
