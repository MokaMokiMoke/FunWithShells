#!/bin/bash
# This finds and deletes files which are identical with a source file using md5sum
# Date: 2020-04-23
# Author: Maximilian Fries, maxfries(at)t-online.de
# Version: 0.1

orig=$(md5sum ~/Downloads/headerOnly.txt | awk '{ print $1 }')

cd ~/Downloads/Bosch
for f in $(ls); do
	chk=$(md5sum $f | awk '{ print $1 }')
	if [ "$chk" == "$orig" ]; then
		echo "File $f has the same hash"
		rm "$f"
	fi
done
