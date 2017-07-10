#!/usr/bin/env bash

fastq=$1			# 1line version of fastq file
mcmodel=$2
indim=3
outdim=3
totdim=$(($indim + $outdim))

function information {
    string=$1
    max=$((${#string}-$totdim+1))
    for start in `seq $max`; do
	echo $start		# position along the read
	echo $string | awk -v start=$start -v totdim=$totdim '{print substr($1,start,totdim)}'| LC_ALL=C grep -f - $mcmodel # output is position and information
    done
}

while IFS= read -r line
do
    # SEGMENT THE READ
    cut_locations=`information $line | paste - - | awk -v indim=$indim '{print $1+indim,$3}' | ./find_peaks.py | tr -d '[].'` # output is the list of location to segment
    echo $line $cut_locations | ./segment.py 
done < "$fastq"



