# -*- coding: utf-8 -*-

import sys
import csv
import numpy as np
from scipy.signal import argrelextrema
import pandas as pd

filename = sys.argv[1]

column_names = ['position','information']
df = pd.read_csv(filename,usecols=[0,3],header=None,names=column_names) # read the data

loc = argrelextrema(df.values[:,1], np.greater) # find location of the maxima
max_df = df.iloc[loc]
word_start = max_df.loc[max_df['information'] > max_df['information'].quantile(0.9)]

filename = '~/Work/dataset/genome_segmentation/word_start.csv'
word_start.to_csv(filename)
