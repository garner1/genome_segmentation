#!/usr/bin/env bash

input=$1			# linearized input file

name=`echo $input|cut -d'/' -f5`
tail -n+2 $input | LC_ALL=C grep -v N | LC_ALL=C sort -t',' -k3,3 -o ~/Work/dataset/genome_segmentation/"$name"
