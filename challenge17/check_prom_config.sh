#!/bin/bash


promtool check config /etc/prometheus/prometheus.yml

EXIT_CODE_CONFIG=$?

promtool check rules /etc/prometheus/rules/*

EXIT_CODE_RULES=$?

if [[ $EXIT_CODE_CONFIG -eq 0 && $EXIT_CODE_RULES -eq 0 ]]; then
    echo "No Error found"
    sudo systemctl restart prometheus
else
    echo "Kindly check the above errors"
fi