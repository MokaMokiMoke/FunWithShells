for i in {0..17280}
do
	temp=$(/opt/vc/bin/vcgencmd measure_temp | cut -d = -f 2 | cut -d "'" -f 1)
	time=$(date +"%Y-%m-%d %T")
	echo $temp $time >> /tmp/temp-log.log
	echo Run $i $time $temp
	sleep 5
done
