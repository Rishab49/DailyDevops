#!/bin/bash

NGINX_EXIT_CODE=$(systemctl status nginx)

if [ $? -ne 0 ];then
    echo "NGINX is not started."
    echo "Attempting to start it"
    systemctl start nginx
else
    echo "NGINX is in running state"
fi

NGINX_EXIT_CODE=$(sudo systemctl status mysqld)
if [ $? -ne 0 ];then
    echo "MYSQL is not started."
    echo "Attempting to start it"
    sudo systemctl start mysqld
else
    echo "MYSQL is in running state"
fi


PROM_EXIT_CODE=$(sudo systemctl status prometheus)
if [ $? -ne 0 ];then
    echo "prometheus is not started."
    echo "Attempting to start it"
    sudo systemctl start prometheus.service
else
    echo "prometheus is in running state"
fi


NE_EXIT_CODE=$(sudo systemctl status nodeexporter)
if [ $? -ne 0 ];then
    echo "Node exporter is not started."
    echo "Attempting to start it"
    sudo systemctl start nodeexporter.service
else
    echo "Node exporter is in running state"
fi


LOKI=$(curl -s http://localhost:3100/ready)

if [ "$LOKI" == "ready" ]; then
    echo "loki is up and running fine"
else
    echo "restarting loki"
    sudo systemctl restart loki
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



