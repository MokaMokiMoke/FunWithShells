#!/bin/bash

gitUrl="https://github.com"
gitUser="MokaMokiMoke"
cloneCmd="git clone"
fetchCmd="git fetch"

declare -a repos=("SeaFile" "BinaryClock" "FunWithShells" "HashBase" "RandomFileGenerator" "FloydWarshall"	\
		"Weihnachtsraetsel" "BCryptTest" "BarGraphDrawer" "NetMonitor" "isFullPrimeRecursive"		\
		"BigIntegerCalculator")

# Init clone
for repo in "${repos[@]}"
do
	if [ -d $repo ]; then
		continue
	fi

	$cloneCmd $gitUrl/$gitUser/$repo
done

# Update Repos

for repo in "${repos[@]}"
do
	cd $repo
	$fetchCmd
	cd ..
done
	
