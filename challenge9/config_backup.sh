#!/bin/bash


if ! id -nG "$USER" | grep -qw "wheel"; then
    echo "Error: This script can only be executed by members of the 'sudo' group."
    exit 1
fi

#Deleting old backip
find . -name "backup*" -type f -mtime +30 -exec rm -rf {} +
# we can use this command as well - find . -name "backup*" -type f -mtime +30 -delete

# Creaing Backup
NGINX_CONF=$(ls -d /etc/nginx 2>/dev/null)
PROM_CONF=$(ls -d /etc/prometheus 2>/dev/null)
GRAFANA_CONF=$(ls -d /etc/grafana 2>/dev/null)
GRAFANA_DATA=$(ls -d /var/lib/grafana/grafana.db 2>/dev/null)

DATE=$(date +'%Y-%m-%d')
FILENAME=$(echo "backup_$DATE.tar.gz")

tar -czf $FILENAME $NGINX_CONF $PROM_CONF $GRAFANA_CONF $GRAFANA_DATA 2>/dev/null


if [[ $? -ne 0 ]];then
    echo "failed to create tar backup hence cannot uploadto s3"
fi



# Uploading backup
aws s3 cp $FILENAME s3://rajrishab-backup

