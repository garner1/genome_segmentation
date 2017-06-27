#!/usr/bin/env bash

filein=$1
fileout=$2
dist_thr=$3
chr=$4

cat $filein |
awk 'NR==1{print $1,$2,"0","0";pos=$1;max=$2;next}{print $1,$2,$1-pos,$2-max;pos=$1;max=$2}' | # print pos,max,delta_pos,delta_max
awk -v t="$dist_thr" '$3>=t || $4>=0 || ($3+$4)==0' |  # equivalent to filtering out those satisfying (delta_pos<t && delta_max<0), i.e. smaller close maxima
awk -v t="$dist_thr" 'NR==1{pos=$1;max=$2;next}$3<t{pos=$1;max=$2}$3>=t{print pos,max;pos=$1;max=$2}' > $fileout # print only if delta_pos >= t

