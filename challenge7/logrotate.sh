#!/bin/bash


LOGFILE_EXISTS=$(ls /var/log/nginx/response.log > /dev/null 2>&1)
if [ $? -ne 0 ]; then
    echo "Current log file doesnot exists"
fi


LOGFILESIZE=$(du -b /var/log/nginx/response.log | awk '{print$1}')


# renaming old log file and compressing old one
if [ $LOGFILESIZE -ge 1024 ]; then
    mv /var/log/nginx/response.log /var/log/nginx/response$(date +%d%m%y).log 
    gzip /var/log/nginx/response$(date +%d%m%y).log
fi

# removing log files older than 7 days

OLD_LOG_FILES=$(sudo find /var/log/nginx/ -name "response*.log" -mtime +7 -delete)


