#!/bin/bash

gitStr="https://github.com/"
declare -a arr=("Seafile" "BinaryClock" "FunWithShells" "Hashbase" "RandomFileGenerator" "FloydWarshall" 	\
		"Weihnachtsraetsel" "isFullPrimeRecursive" "BCryptTest" "BarGraphDrawer" "NetMonitor"		\
		"BigIntegerCalculator")

# Initially clone all repos
for i in "${arr[@]}"
do
	if [ -d $i ]; then
		continue
	fi

	git clone $gitStr$i
done

# Update Repos

for i in "${arr[@]}"
do
	git fetch $gitStr$i
done
