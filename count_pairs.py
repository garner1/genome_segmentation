#! /usr/bin/python

from itertools import combinations
from collections import Counter
import os.path
import sys
import re

file_name = str(sys.argv[1])    # ex: $datadir/segmented_chr??.dic
window = int(sys.argv[2])

def collect_pairs(file_name,window):
    pair_weight = Counter()     # IT IS PROB A GOOD IDEA TO SPLIT THE TWO COUNTER CREATION IN TWO PARALLEL OPERATIONS!!!
    pair_counter = Counter()
    dictionary = []
    with open(file_name, 'rb') as infile:
        for line in infile:
            lista = re.split('\t',line.strip())
            dictionary.append(lista[3])
    print len(dictionary)
    for word_index in range(len(dictionary)-window):
        for context_index in range(word_index+1,word_index+window+1):
            weight = 1.0/abs(word_index-context_index)                    
            pair_weight[(dictionary[word_index],dictionary[context_index])] += weight
            pair_weight[(dictionary[context_index],dictionary[word_index])] += weight
            pair_counter[(dictionary[word_index],dictionary[context_index])] += 1
            pair_counter[(dictionary[context_index],dictionary[word_index])] += 1
    return pair_weight,pair_counter
    
w,p = collect_pairs(file_name,window)

with open(file_name + "_counter.txt",'w') as f:
    for k,v in  p.most_common():
        f.write( "{} {}\n".format(k,v) )
with open(file_name + "_weight.txt",'w') as f:
    for k,v in  w.most_common():
        f.write( "{} {}\n".format(k,v) )

print 'Done with' + file_name
