#!/bin/bash
# This script removes every line in all files within a directory which contains a specific string using sedr
# Date: 2020-04-23
# Author: Maximilian Fries, maxfries(at)t-online.de
# Version: 0.1

str=$(cat ~/Downloads/headerOnly.txt)
ctr=0
cd Bosch

#for f in $(grep -rl ./  -e '$str'); do
for f in $(ls); do
	#sed '/$str/d' $f > $f
	sed -i '/findLineContainingStringAndDeleteLine/d' $f 
	echo $ctr
	ctr=$((ctr+1))
done
