#!/bin/bash
echo Text-{1..3}-{1..3} | tr " " "\n" > sample.txt

file=sample.txt
curr=""
layer=""
lines=$(cat $file | wc -l)

for (( line=1;line<=$lines;line++)); do
curr=$(sed -n "$line p" "$file")
layer=$(echo $curr | awk 'BEGIN {FS = "-" } ; { print $2 }')
echo $curr >> Text-$layer
done
