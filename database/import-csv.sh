#!/bin/bash
# Maximilian Fries, 2020-07-30

# Database params
dbUsr="foo"
dbPasswd="bar"
database="test"

# File path params
sqlFile="/home/max/sql/import-csv.sql" 		# Contains SQL Statement for SQL-Database
hashFile="/home/max/sql/foo.csv.md5"		# Store previous changed CSV hash value
csvFile="/home/max/share/csv-import/foo.csv"	# CSV file to load
logFile="/var/log/import-csv"			# File to logg events
logLimit=40000					# Max. number of log lines (~ 40k/14 days)

# Check if CSV has changed
oldHash=`cat $hashFile`
newHash=$(md5sum $csvFile | cut -d' ' -f 1)

# Load CSV into database if CSV has changed
if [ $oldHash != $newHash ]; then
	cat $sqlFile | mysql -u $dbUsr --password=$dbPasswd $database
	echo "Import CSV File ($csvFile) has changed" >> $logFile
	echo $newHash > $hashFile
else
	echo "Import CSV File ($csvFile) has NOT changed" >> $logFile
fi
date >> $logFile

# Run only per hour at 30 minutes (probablistic)
if [ $(date +%M) -eq 30 ]; them
	# Trim logfile to maximum $logLimit lines
	logLines=$(cat $logFile | wc -l) 		# Length of logFile in number of lines

	if [ $logLines -gt $logLimit ]; then 		# -gt = greater than
		delim=$(echo "$logLines - $logLimit")
		sed -i "1,$delim"d $logFile		# Delete 1st to $delim lines from logFile
	fi
fi
