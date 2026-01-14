#!/bin/bash

HTTP_STATUS=$(curl -sI http://localhost:3000/login | grep -i "HTTP")

if [[ "$HTTP_STATUS" == *"200 OK"* ]]; then
    echo "SUCCESS"
else
    logger -p local5.emerg "Grafana dashboard is not reachable"
fi