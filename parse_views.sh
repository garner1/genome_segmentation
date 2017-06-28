#!/usr/bin/env bash

input=$1			# linearized input file
datadir=$2			# path to local data directory

name=`echo $input|cut -d'/' -f5`
tail -n+2 $input | 		# remove header
LC_ALL=C grep -v N | 		# remove views with undetermined bases
LC_ALL=C sort -t',' -k3,3 -o "$datadir"/"$name"
