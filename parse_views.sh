#!/usr/bin/env bash

input=$1			# linearized input file

temp="$(mktemp)"

tail -n+2 $input | LC_ALL=C grep -v N | LC_ALL=C sort -t',' -k3,3 -o $input
