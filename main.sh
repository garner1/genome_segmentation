#!/usr/bin/env bash

# in_dim=6
# out_dim=3
datadir=~/Work/dataset/genome_segmentation
chr=chr21
threshold_on_conditionInformation=0.1
window=10

# echo 'First run the R-script which produces the relevant view (chromosomes, genes, etc) and the relevant markov chain parameters.'
# Rscript get_kmer.R		
# R < get_kmer.R --no-save  
# echo 'Done'

# echo 'Combine Markov chain models of the genome...'
# bash ./MC_mixing.sh $datadir $chr
# echo 'Done'

# echo "Find local maxima in the information profile ..."
# bash ./segmentation.sh $datadir $threshold_on_conditionInformation $chr
# echo "Done"

# echo "Make dictionary ..."
# bash ./associate_seq_to_locations.sh $datadir $chr
# echo "Done"

# echo "Produce word-context counts ..."
# echo "Create ordered word pairs (count how many times word1 is to the left of word2 inside a context window) within a context of size window ..."
# bash ./word_count.sh $window $datadir $chr
# echo "Done"

# echo "Prepare vocabulary: a 1to1 word-index map"
# bash ./get_vocabulary.sh $datadir $chr
# echo "Done"

# echo "Prepare the final matrix chr??.mat which has wordIndex-contextIndex-count-rowMarginal-colMarginal format"
# bash ./prepare_matrix.sh $datadir $chr
# echo "Done"

D=`cat $datadir/vocabulary|wc -l` # size of the vocabulary
k=10				  # shift factor in SPPMI
rank=2				  # truncation dim in svd
python cooccurrence_matrix.py $datadir/"$chr".mat $D $k $rank
echo "Done"

# rm -f $datadir/segmented__"$chr".dic_counter.txt.mat
# rm -f $datadir/vocabulary $datadir/*{joined,bed,csv,dic,txt,normalized*,contextMarginale,wordMarginale}

