#!/bin/bash

output=$(sudo grep "Failed password" /var/log/secure | grep -v "COMMAND" | wc -l)
echo "system_ssh_failed_ssh_login_counts $output" > /var/lib/node_exporter/textfile_collector/ssh_failures.prom.$$
mv /var/lib/node_exporter/textfile_collector/ssh_failures.prom.$$ /var/lib/node_exporter/textfile_collector/ssh_failures.prom