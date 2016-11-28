#!/bin/bash                                                                                                                                 
# Simple benchmark script for sysbench CPU test                                                                                             
# Usage ./benchmark.sh [maxThreads]                                                                                                         
                                                                                                                                            
# Default value for threads                                                                                                                 
maxThreads=4                                                                                                                                
maxPrimes=200                                                                                                                               
                                                                                                                        
                                                                                                                                            
# If argument was passed set threads                                                                                                        
if [ $# -eq 1 ]                                                                                                                             
        then                                                                                                                                
        $maxThreads=$1                                                                                                                      
fi                                                                                                                                          
                                                                                                                                            
clock=$(lscpu | grep MHz | cut -d ":" -f2 | cut -d "," -f1)                                                                                                
echo CPU clock: $clock                                                                                                                      
echo                                                                                                                                        
                                                                                                                                            
for ((numThreads=1; numThreads <= $maxThreads; numThreads=numThreads*2))                                                                    
        do                                                                                                                                  
        echo $testRuns test runs with $numThreads threads:                                                                                  
        for run in {1..3}                                                                                                           
                do                                                                                                                          
                time=$(sysbench --test=cpu --cpu-max-prime=$maxPrimes --num-threads=$numThreads run | \                                     
                grep "execution time" | cut -d ":" -f2 | cut -d "/" -f1)                                                                    
                echo Run $run with $numThreads threads: $time s                                                                             
        done                                                                                                                                
echo                                                                                                                                        
done  
