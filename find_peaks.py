# -*- coding: utf-8 -*-

import sys
import csv
import numpy as np
from scipy.signal import argrelextrema
import pandas as pd

filename = sys.argv[1]
outfile = sys.argv[2]
percentile = float(sys.argv[3])  # e.g.: 0.90

column_names = ['position','information']
df = pd.read_csv(filename,usecols=[0,1],sep=' ',header=None,names=column_names) # read the data

loc = argrelextrema(df.values[:,1], np.greater) # find location of the maxima
max_df = df.iloc[loc]

threshold = max_df['information'].quantile(percentile)
word_edge = max_df.loc[max_df['information'] > threshold]

word_edge.to_csv(outfile)
