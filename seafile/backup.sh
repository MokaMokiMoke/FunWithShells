#!/bin/bash
#
# Script to backup your seafile database and user-data
# name:		backup.sh
# author: 	maximilian.fries.25@stud.tu-darmstadt.de
# date: 	2018-09-23
# version:	0.10

seafileDir=/mnt/pidrive/seafile
backupDir=/mnt/backup
logDir=$seafileDir/logs
mySqlUser=root
mySqlHost=127.0.0.1
sqlPasswd=somePassword
timeString=`date +"%Y-%m-%d-%H-%M-%S"`
logFile=$logDir/backup-$timeString.log

magenta="\033[35m"                                                                                                                                                                            
green="\033[32m"                                                                                                                                                                              
def="\033[0m" 

timeToLog()
{
echo -e `date +"%Y-%m-%d-%H-%M-%S"` | tee -a $logFile
}

# Mount Backup Share (if not done at bootup)
sudo mount -a

# Write enviromental variables and basic information to log file
env 								| tee -a $logFile
id 								| tee -a $logFile

# Write Start Time-Stamp to Log File
echo -e "$magenta Starting Backup at $def" 				| tee -a $logFile
timeToLog

# Delete old log files
echo -e "$magenta Deleting old log files $def"			| tee -a $logFile
find $seafileDir/logs -maxdepth 1 -mtime +30 -type f -delete
echo -e "$green \t Logs checked $def \n"				| tee -a $logFile
timeToLog

# Looking for 30 days old database backups and delete them
echo -e "$magenta Looking for old databases $def"		| tee -a $logFile
ifind $backupDir/databases -maxdepth 1 -mtime +30 -type f -delete
echo -e "$green \t Databases checked $def \n"			| tee -a $logFile
timeToLog

# Stop SeaFile Service
echo -e "$magenta Stopping SeaFile Deamon $def"			| tee -a $logFile
sudo service seafile stop 2>&1					| tee -a $logFile
echo -e "$green \t Deamon stopped $def \n"			| tee -a $logFile
timeToLog

# Wait 10 seconds
echo -e "$magenta Wait for 10 seconds $def"			| tee -a $logFile
echo -n "\t"
for i in {1..10}; do echo -en "$green $i $def"; sleep 1; done
echo -e "$magenta Finished waiting. $def \n"			| tee -a $logFile
timeToLog

# Garbage Collector
echo -e "$magenta Starting GC $def"				| tee -a $logFile
$seafileDir/seafile-server-latest/seaf-gc.sh 2>&1		| tee -a $logFile
echo -e "$magenta Finished GC $def"				| tee -a $logFile
timeToLog

# Create MySQL Dumps and back them up
echo -e "$magenta Creating SQL Dumps $def"			| tee -a $logFile
mysqldump -h $mySqlHost --user=$mySqlUser --password=$sqlPasswd --opt ccnet-db	 | pigz > $backupDir/databases/ccnet-db.sql.$timeString\.gz
mysqldump -h $mySqlHost --user=$mySqlUser --password=$sqlPasswd --opt seafile-db | pigz > $backupDir/databases/seafile-db.sql.$timeString\.gz
mysqldump -h $mySqlHost --user=$mySqlUser --password=$sqlPasswd --opt seahub-db  | pigz > $backupDir/databases/seahub-db.sql.$timeString\.gz
echo -e "$green \t Dumps created $def \n"			| tee -a $logFile
timeToLog

# Start SeaFile Service
echo -e "$magenta Starting SeaFile Deamon $def"			| tee -a $logFile
sudo service seafile start 2>&1					| tee -a $logFile
echo -e "$green \t Deamon Started $def \n"			| tee -a $logFile
timeToLog

# Create a full backup of complete seafile files
echo -e "$magenta Starting rsync Bacup $def"			| tee -a $logFile 
rsync -avz --delete --log-file=$logFile --exclude 'ccnet.sock' $seafileDir/ $backupDir/data/
echo -e "$green \t Data Backup finished $def \n"		| tee -a $logFile
timeToLog

# Backup Let´s Encrypt Folder
echo -e "$magenta Backup of /etc/letsencrypt/ $def"		| tee -a $logFile
ifind $backupDir/letsencrypt -maxdepth 1 -mtime +60 -type f -delete
tar cf - /etc/letsencrypt/ | pigz > $backupDir/letsencrypt/letsencrypt_$timeString\.tar.gz
echo -e "$green \t Backup of letsencrypt created $def \n"	| tee -a $logFile
timeToLog

# Backup nginx Config 
echo -e "$magenta Backup /etc/nginx/ $def"			| tee -a $logFile
ifind $backupDir/nginx -maxdepth 1 -mtime +60 -type f -delete
tar cf - /etc/nginx/ | pigz > $backupDir/nginx/nginx_$timeString\.tar.gz
echo -e "$green \t Backup of nginx created $def \n"		| tee -a $logFile
timeToLog

# compress rsync log file
echo -e "$magneta Compressing and copying log files $def"	| tee -a $logFile
pigz --best $logFile
cp $logFile.gz $backupDir/logs
