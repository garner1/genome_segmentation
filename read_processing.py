#!/usr/bin/env python

import sys
import csv
import numpy as np
from scipy.signal import argrelextrema
import pandas as pd
from itertools import combinations
from collections import Counter
import os.path


fastq_file = str(sys.argv[1])
column_names = ['6mer','information']
model = pd.read_csv('/home/garner1/Work/dataset/genome_segmentation/transitionMatrix_3to3.csv',sep=' ',names=column_names)
column_names = ['read']
reads = pd.read_csv(fastq_file, header=None,names=column_names)

# HARDCODED DIMENSION PARAMETERS: 6,5,4,3...
pair_weight = Counter()     # IT IS PROB A GOOD IDEA TO SPLIT THE TWO COUNTER CREATION IN TWO PARALLEL OPERATIONS!!!
pair_counter = Counter()

for index, row in reads.iterrows():
    kmers = pd.DataFrame([row['read'][i:i+6] for i in range(len(row['read'])-5)])
    kmers.columns = ['6mer']
    infodata = kmers.merge(model, on='6mer', how='left')
    loc = argrelextrema(infodata.values[:,1], np.greater) # find location of the maxima
    max_df = infodata.iloc[loc]
    new_df = max_df.copy(deep=True)
    index_list = list(max_df.index.values)
    for ind in range(len(index_list)-1):
        deltaLoc = index_list[ind+1] - index_list[ind]
        deltaInfo = float(max_df.loc[index_list[ind+1]]['information']) - float(max_df.loc[index_list[ind]]['information'])
        if (deltaLoc <= 3) and (deltaInfo < 0) and (index_list[ind+1] in new_df.index):
            new_df.drop(index_list[ind+1],inplace=True)
        if (deltaLoc <= 3) and (deltaInfo >= 0) and (index_list[ind] in new_df.index):
            new_df.drop(index_list[ind],inplace=True)
    maxima = list(new_df.index.values)
    if len(maxima)>3:
        read = row['read']
        dictionary = []
        for ind in range(len(maxima)):
            if ind == 0: 
                start = 0
                end = maxima[ind]+3
                dictionary.append(read[start:end])
            if ind > 0 and ind < len(maxima):
                start = maxima[ind-1]+3
                end = maxima[ind]+3
                dictionary.append(read[start:end])
            if ind == len(maxima):
                start = maxima[ind-1]+3
                end = maxima[ind]+3
                dictionary.append(read[start:end])
        start = maxima[-1]+3
        end = len(read)
        dictionary.append(read[maxima[-1]+3:])
        if len(dictionary) >= 2:
            for word_index in range(len(dictionary)):
                for context_index in range(word_index+1,len(dictionary)):
                    weight = 1.0/abs(word_index-context_index)                    
                    pair_weight[(dictionary[word_index],dictionary[context_index])] += weight
                    pair_weight[(dictionary[context_index],dictionary[word_index])] += weight
                    pair_counter[(dictionary[word_index],dictionary[context_index])] += 1
                    pair_counter[(dictionary[context_index],dictionary[word_index])] += 1

with open(fastq_file + "_counter.txt",'w') as f:
    for k,v in  pair_counter.most_common():
        f.write( "{} {}\n".format(k,v) )
with open(fastq_file + "_weight.txt",'w') as f:
    for k,v in  pair_weight.most_common():
        f.write( "{} {}\n".format(k,v) )

