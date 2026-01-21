#!/bin/bash


#logging in to mysql

mysql -e "SELECT 1;" > /dev/null


if [ $? -eq 0 ]; then
    echo "MYSQL is up and running fine"
else
    echo "Error occured"
    logger -p local0.warn "MYSQL is not responding"
fi