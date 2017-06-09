#!/usr/bin/env bash

input=$1			# linearized input file

temp="$(mktemp)"

LC_ALL=C join -1 1 -2 3 -o 2.1 2.2 1.1 1.2 -t','  ~/*_chrY_3to1_LR.csv | LC_ALL=C sort -t',' -k1,1n | head
