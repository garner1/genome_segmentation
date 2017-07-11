#!/usr/bin/env python

import sys
import csv
import numpy as np
import pandas as pd
import os.path

filename = '/home/garner1/Work/dataset/genome_segmentation/joined.read_counter.txt'
# df = pd.read_csv(filename, sep='\t')

## gives TextFileReader, which is iteratable with chunks of 1000 rows.
tp = pd.read_csv(filename,sep='\t',header=None,iterator=True, chunksize=100000) 
## df is DataFrame. If error do list(tp)
df = pd.concat(list(tp), ignore_index=True)
