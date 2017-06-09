#!/usr/bin/env bash

input=$1			# linearized input file

temp="$(mktemp)"

tail -n+2 $input | cut -d',' -f2- | sed 's/"//g' > $temp && mv $temp $input 
