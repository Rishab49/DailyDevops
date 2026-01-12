#!/bin/bash


RESPONSE_TIMES=$(awk '{print $3}' /var/log/nginx/response.log)

SLOWEST_PROCESS=$(echo "$RESPONSE_TIMES" | sort -n | tail -n 3)

AVERAGE_RESPONSE_TIME=$(awk 'BEGIN{sum=0; count=0} {sum += $3; count++} END {printf sum/count}' /var/log/nginx/response.log)

echo $AVERAGE_RESPONSE_TIME
echo "SLOWEST REQUESTS ${SLOWEST_PROCESS}"


