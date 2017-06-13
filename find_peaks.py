# -*- coding: utf-8 -*-

import sys
import csv
import numpy as np
from scipy.signal import argrelextrema
import pandas as pd

filename = sys.argv[1]
outfile = sys.argv[2]

column_names = ['position','information']
df = pd.read_csv(filename,usecols=[0,3],header=None,names=column_names) # read the data

loc = argrelextrema(df.values[:,1], np.greater) # find location of the maxima
max_df = df.iloc[loc]
word_edge = max_df.loc[max_df['information'] > max_df['information'].quantile(0.90)]

word_edge.to_csv(outfile)
