#!/usr/bin/env python

import sys
import csv
import numpy as np
import pandas as pd

df = pd.read_csv(sys.stdin,sep=' ',header=None)

read = df.values[0,0]
context = []
for ind in range(1,len(df.values[0,:])):
    if ind == 1: 
        context.append(read[0:df.values[0,ind]])
    if ind > 1 and ind < len(df.values[0,:]):
        context.append(read[df.values[0,ind-1]:df.values[0,ind]])
    if ind == len(df.values[0,:]):
        context.append(read[df.values[0,ind-1]:df.values[0,ind]])
context.append(read[df.values[0,ind]:])

print context



###################################################################
# filename = sys.argv[1]
# outfile = sys.argv[2]
# percentile = float(sys.argv[3])  # e.g.: 0.90

# column_names = ['position','information']
# df = pd.read_csv(filename,usecols=[0,1],sep=' ',header=None,names=column_names) # read the data

# loc = argrelextrema(df.values[:,1], np.greater) # find location of the maxima
# max_df = df.iloc[loc]

# threshold = max_df['information'].quantile(percentile)
# word_edge = max_df.loc[max_df['information'] > threshold]

# word_edge.to_csv(outfile)
