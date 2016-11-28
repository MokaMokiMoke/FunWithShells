#!/bin/bash 
# Simple benchmark script for sysbench CPU test
# Usage ./benchmark.sh [maxThreads] [maxPrimes] [numRuns]

# Default value for threads
maxThreads=8
maxPrimes=20000
numRuns=5

# If argument handling
if [ $# -eq 1 ]; then
	if [ $1 == "--help" ]; then
		echo "Usage ./benchmark.sh [maxThreads] [maxPrimes] [numRuns]"
		exit
	fi
	maxThreads=$1
fi

if [ $# -eq 2 ]; then
	maxThreads=$1
	maxPrimes=$2
fi

if [ $# -eq 3 ]; then
	maxThreads=$1
	maxPrimes=$2
	numRuns=$3
fi

clock=$(lscpu | grep MHz)
echo CPU clock:    $clock
echo Max. Threads: $maxThreads
echo Max. Primes:  $maxPrimes
echo No. Runs:     $numRuns 
echo

for ((numThreads=1; numThreads <= $maxThreads; numThreads*=2))
	do
	echo $numThreads threads:
	for run in {1..3}
		do
		time=$(sysbench --test=cpu --cpu-max-prime=$maxPrimes --num-threads=$numThreads run | \
		grep "execution time" | cut -d ":" -f2 | cut -d "/" -f1)
		echo Run $run with $numThreads threads: $time s     
	done
	echo
done
