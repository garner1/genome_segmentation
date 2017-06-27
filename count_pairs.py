#! /usr/bin/python

from itertools import combinations
from collections import Counter
import os.path
import sys
import re

file_name = str(sys.argv[1])    # ex: $datadir/word_{forward,reverse}.dic
window = int(sys.argv[2])

def collect_pairs(file_name,window):
    pair_counter = Counter()
    with open(file_name, 'rb') as infile:
        count = 0
        context = []
        for line in infile:
            count += 1
            lista = re.split('\t',line.strip())
            context.append(lista[3])
            if count > window:
                for index in range(window):
                    weight = 1.0/abs(window-index)                    
                    pair_counter[(context[count-window],context[index])] += weight
                context = []
                count = 0
    return pair_counter
    
p = collect_pairs(file_name,window)

with open(file_name + "_counter.txt",'w') as f:
    for k,v in  p.most_common():
        f.write( "{} {}\n".format(k,v) )

print 'Done with' + file_name
