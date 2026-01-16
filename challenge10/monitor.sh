#!/bin/bash

NGINX_EXIT_CODE=$(sudo systemctl status nginx)
if [ $? -ne 0 ];then
    echo "NGINX is not started."
    echo "Attempting to start it"
    sudo systemctl start nginx
else
    echo "NGINX is in running state"
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