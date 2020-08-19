#!/bin/bash

declare -a hosts=("heise.de" "195.50.140.114" "9.9.9.9" "1.1.1.1" "netflix.com" "google.com" "8.8.8.8" "192.168.0.1")
noOfPings=5
timeout=20

while true; do
	 for host in "${hosts[@]}"; do
		echo -e `date +"%Y-%m-%d_%H-%M-%S\c"` | tee -a $host.log
		echo -e ";\c" | tee -a $host.log
		ping -c $noOfPings -w $timeout $host | grep time= | rev | cut -d " " -f2 | rev | \
		tr '\n' ';' | sed 's/time=//g' | tee -a $host.log
		printf "\n" | tee -a $host.log
	done
done
