#!/usr/bin/env bash

file=$1

cat $file | cut -f-2 | tr '\t' '\n' | LC_ALL=C sort | LC_ALL=C uniq | cat -n | awk '{print $2,$1}' > "$file"_vocabulary
