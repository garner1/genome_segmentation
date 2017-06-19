#!/usr/bin/env bash

input=$1			# linearized input file

name=`echo $input|cut -d'/' -f5`
tail -n+2 $input | cut -d',' -f2- | sed 's/"//g' > ~/Work/dataset/genome_segmentation/"$name"
