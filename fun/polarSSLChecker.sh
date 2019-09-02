#!/bin/bash
# Polar Certificate checker

logfile=log.txt
expired="Jul 12 23:59:59 2018 GMT"
red="\033[0;31m"
green="\033[0;32m"
nocol="\033[0m"

while true; do

echo -n "Checking time at: " | tee $logfile
echo  $(date) | tee $logfile
echo | openssl s_client -servername polarremote.com -connect polarremote.com:443 2>/dev/null | openssl x509 -noout -dates | grep notAfter | cut --delimiter="=" -f 2 | tee $logfile
new=$(echo | openssl s_client -servername polarremote.com -connect polarremote.com:443 2>/dev/null | openssl x509 -noout -dates | grep notAfter | cut --delimiter="=" -f 2)

if [ "$new" != "$expired" ]
then
  echo -e "$green Haleluia! $nocol" | tee $logfile
else
  echo -e "$red Certificate still invalid :( $nocol" | tee $logfile
fi

echo -e "" |tee $logfile
sleep 10


done
