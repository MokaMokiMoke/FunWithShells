#!/bin/bash

if [ $# -eq 2 ]; then
  wait=$1
  interval=$2
elif [ $# -eq 1 ]; then
  wait=$1
elif [ $# -eq 0 ]; then
  wait=90
  interval=20
fi

if [ $wait -lt 2 ]; then
  $wait=3;
fi

dir=/home/pi/bash/img
dlsrc=http://www.hunderdorf.de/webcam/image.jpg
couter=0
now=$(date +"%y_%m_%d")
logfile=$dir/log_$now.txt
delfile=$dir/del_$now.txt
touch $logfile
touch $delfile

while true
do
  now=$(date +"%y_%m_%d-%H:%M:%S")
  wget -q $dlsrc -O $dir/$now.jpg

  counter=$[$counter+1]
  
  printf "%s;%05d;\n" $now $counter >>$logfile

  if [ $counter -ge $interval -a $(($counter % $interval)) -eq 0 ]; then
    echo "Delte Vorgang bei Counter $counter" >>$delfile
    fdupes -f $dir | grep -v '^$' | xargs rm -v >>$delfile
    echo "" >>$delfile
    mv $dir/*.jpg $dir/fin
  fi

  if [ $counter -ge 1 -a $(($counter % $(($wait*$interval/2)))) -eq 0 ]; then
    array=$(ls $dir/fin | tail -n $(($wait*$interval)))
    for file in $array; do
      mv $dir/fin/$file $dir/tmp
    done
    fdupes -f $dir/tmp | grep -v '^$' | xargs rm -v >>$delfile
    mv $dir/tmp/*.jpg $dir/fin
  fi

  sleep $wait 
done
