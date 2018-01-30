while read p
	do nslookup $p
done <domains.txt
