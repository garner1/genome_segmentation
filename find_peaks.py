#!/usr/bin/env python

import sys
import csv
import numpy as np
from scipy.signal import argrelextrema
import pandas as pd

column_names = ['position','information']
df = pd.read_csv(sys.stdin,usecols=[0,1],sep=' ',header=None,names=column_names)

loc = argrelextrema(df.values[:,1], np.greater) # find location of the maxima
max_df = df.iloc[loc]
new_df = max_df.copy(deep=True)

index_list = list(max_df.index.values)
for ind in range(len(index_list)-1):
    deltaLoc = max_df.loc[index_list[ind+1]]['position'] - max_df.loc[index_list[ind]]['position']
    deltaInfo = max_df.loc[index_list[ind+1]]['information'] - max_df.loc[index_list[ind]]['information']
    if (deltaLoc <= 3) and (deltaInfo < 0) and (index_list[ind+1] in new_df.index):
        new_df.drop(index_list[ind+1],inplace=True)
    if (deltaLoc <= 3) and (deltaInfo >= 0) and (index_list[ind] in new_df.index):
        new_df.drop(index_list[ind],inplace=True)
print new_df.values[:,0]


