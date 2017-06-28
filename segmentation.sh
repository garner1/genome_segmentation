#!/usr/bin/env bash

datadir=$1
threshold_on_conditionInformation=$2
chr=$3

python find_peaks.py $datadir/joined_"$chr".csv $datadir/plusStrand-forward__"$chr".csv $threshold_on_conditionInformation # find all extrema and threshold based on the condition_info value
tail -n+2 $datadir/plusStrand-forward__chr21.csv | tr ',' ' '| cut -d' ' -f2- > $datadir/aux && mv $datadir/aux $datadir/plusStrand-forward__chr21.csv # parsing
bash aggregate.sh $datadir/plusStrand-forward__chr21.csv $datadir/aux3.bed 3 $chr # cluster extrema closer than 3
echo "Done d=3"
bash aggregate.sh $datadir/aux3.bed $datadir/aux4.bed 4 $chr # cluster extrema closer than 4
echo "Done d=4"
bash aggregate.sh $datadir/aux4.bed $datadir/aux5.bed 5 $chr # cluster extrema closer than 5
echo "Done d=5"
bash aggregate.sh $datadir/aux5.bed $datadir/aux6.bed 6 $chr # cluster extrema closer than 6
echo "Done d=6"
bash aggregate.sh $datadir/aux6.bed $datadir/aux7.bed 7 $chr # cluster extrema closer than 7
echo "Done d=7"
bash aggregate.sh $datadir/aux7.bed $datadir/aux8.bed 8 $chr # cluster extrema closer than 8
echo "Done d=8"
bash aggregate.sh $datadir/aux8.bed $datadir/aux9.bed 9 $chr # cluster extrema closer than 9
echo "Done d=9"
cat $datadir/aux9.bed |
awk -v chr="$chr" 'NR==1{start=$1;next}{OFS="\t";print chr,start,$1,"forward",$2,"+";start=$1}' > $datadir/segmented__"$chr".bed 
rm -f $datadir/aux?.bed
