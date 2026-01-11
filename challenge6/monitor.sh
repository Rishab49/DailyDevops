#!/bin/bash

NGINX_EXIT_CODE=$(systemctl status nginx)


if [ $? -ne 0 ];then
    echo "NGINX is not started."
    echo "Attempting to start it"
    sudo systemctl start nginx
else
    echo "NGINX is in running state"
fi

df -h | awk '{print $1, $5}' | while IFS= read -r line; do 
MOUNT_POINT=$(echo $line | awk '{print$1}') 
UTILIZATION_PERCENTAGE=$(echo $line | awk '{print$2}') 

UTILIZATION=$(echo $UTILIZATION_PERCENTAGE | tr -d "%")

echo $UTILIZATION
if (( $UTILIZATION >= 90 )); then 
    logger -p local5.warn "The utilization of ${MOUNT_POINT} is above threshold and currently standing at ${UTILIZATION_PERCENTAGE}"
fi
done

top -b -n 1| head -n 12 | tail -n 5 >> process_logs.txt



