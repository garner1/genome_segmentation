#!/usr/bin/env bash

# in_dim=3
# out_dim=3
datadir=~/Work/dataset/genome_segmentation

# GENERATE FASTQ FILES USING NEAT OR VARSIM_RUN
# !!! check directories and parameters !!!!
parallel "python ~/tools/neat-genreads/genReads.py -r ~/igv/genomes/hg19.fasta -R 50 -o ~/Work/dataset/genome_segmentation/simulated_data -c 1 --job {} 32" ::: `seq 32`
python ~/tools/neat-genreads/mergeJobs.py -i  /home/garner1/tool_test/neat -o  /home/garner1/tool_test -s ~/tools/samtools-1.2

# Run the R-script which produces the reference homogeneous markov model: MC_model_from_fastq.R. The output file is contained in ~/Work/dataset/genome_segmentation/transitionMatrix_3to3.csv'

echo 'Split fastq files into chuncks ...'
split -l 100000 --additional-suffix=.read $datadir/test-1line.fastq # THE INPUT FILE CONTAINS ONLY THE READ SEQUENCE
echo 'Done!'

echo 'Create sentences ...'
parallel "bash create_sentences.py {}" ::: $datadir/x?? # these are pickle files TO BE USED IN GENSIM WORD2VEC sequentially, do not concatenate with cat
echo 'Done!'

echo 'Run gensim word2vec implementation ...'
bash word2vector.py ~/Work/dataset/genome_segmentation/sentence_directory 
echo 'Done!'
#########################################################################
# echo 'Process the reads into word cooccurrences ...'
# parallel "./read_processing.py {}" ::: $datadir/x??
# echo 'Done'

# echo 'Pull together the output reads ...'
# cat $datadir/*.read_weight.txt | tr -d "()\',"  | tr ' .' '\t,' | datamash -s -g 1,2 sum 3 | tr ',' '.' > $datadir/joined.read_weight.txt & pid1=$!
# cat $datadir/*.read_counter.txt | tr -d "()\',"  | tr ' ' '\t' | datamash -s -g 1,2 sum 3 > $datadir/joined.read_counter.txt & pid2=$!
# wait $pid1
# wait $pid2
# echo 'Done'

# echo 'Get the word-index map ...'
# bash get_vocabulary.sh $datadir/joined.read_counter.txt
# echo 'Done'

#########################################################################
# rm -f $datadir/contexts.txt
# echo 'Apply MC model to fastq file'
# bash ./MC_mixing.sh $datadir/test-1line.fastq $datadir/transitionMatrix_3to3.csv 
# # | tr -d "[]\' " | tr ',' '\t' >> $datadir/contexts.txt
# echo 'Done'

# echo 'Count word co-occurrences'
# ./count_pairs.py $datadir/contexts.txt
# echo 'Done'


###########################################################################
# in_dim=3
# out_dim=3
# datadir=~/Work/dataset/genome_segmentation
# threshold_on_conditionInformation=0.1
# window=10

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


# echo "Filter the paired weigth-count matrix based on min number of counts"
# cat $datadir/paired_count-weight.txt | awk '$4>1{print $1"\t"$2"\t"$3}' > $datadir/word-context-weight.txt
# echo "Done"

# echo "Prepare vocabulary: a 1to1 word-index map"
# bash ./get_vocabulary.sh $datadir
# echo "Done"

# echo "Prepare the final matrix chr??.mat which has wordIndex-contextIndex-count-rowMarginal-colMarginal format"
# bash ./prepare_matrix.sh $datadir $chr
# echo "Done"

# D=`cat $datadir/vocabulary|wc -l` # size of the vocabulary
# k=1				  # shift factor in SPPMI
# rank=2				  # truncation dim in svd
# python cooccurrence_matrix.py $datadir/"$chr".mat $D $k $rank
# echo "Done"

# rm -f $datadir/segmented__"$chr".dic_counter.txt.mat
# rm -f $datadir/vocabulary $datadir/*{joined,bed,csv,dic,txt,normalized*,contextMarginale,wordMarginale}

