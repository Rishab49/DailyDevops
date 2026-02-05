# Challenge 16: The Alerting Master (PromQL & Alertmanager)

Scenario: You have the metrics flowing, but you're currently staring at the screen waiting for things to break. A real SRE wants the system to scream when there's trouble. You need to configure Prometheus to identify "incidents" and Alertmanager to handle the noise.

Task Requirements:
Observability (Bucket D): Prometheus Rules

Create a file named alert.rules.yml.

Define an alert InstanceDown that triggers if any target is unreachable for more than 1 minute.

Define an alert HighCPUUsage that triggers if the CPU usage (derived from Node Exporter) stays above 80% for more than 2 minutes.

Link this file in your prometheus.yml under the rule_files section.

Linux Admin (Bucket A): Alertmanager Installation

Download and install the Alertmanager binary (keep it agentless, no Docker).

Create a systemd unit file alertmanager.service to manage it.

Configure alertmanager.yml to receive alerts from Prometheus. To keep it free and simple, set the "receiver" to a webhook or just verify the alerts reach the Alertmanager UI on port 9093.

Logic (Bucket C): PromQL Mastery

Write a PromQL query that calculates the percentage of free memory available on your Linux host.

Write a PromQL query that shows the rate of disk reads (bytes per second) over the last 5 minutes.

Success Criteria:
Submit the alert.rules.yml file with your two alert definitions.

Submit the prometheus.yml snippet showing how you included the rules and the alertmanager target.

Submit the two PromQL queries.


# Solution

## Alert rules
I have created the rules file with 2 alerts 
1. InstanceDown : this alert will trigger when any of the target instance is not reachable for more than 2 minutes
2.  HighCPUUtilization: alert wil trigger when the utilization of any target is above 80% for 2 minutes


I have created the rules inside  /etc/prometheus/rules directory and configured prometheus to use all of the files inside this dir as alert configs
using below 

```yml
rule_files:
  - rules/*
```

```yml
groups:
  - name: Rule1
    rules:
      - alert: InstanceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Target {{ $labels.instance }} is down"
      - alert: HighCPUUtilization
        expr: 100 * (1 - avg by(instance) (rate(node_cpu_seconds_total{node="idle"}[2m]))) > 80
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Target {{ $labels.instance }} is having high CPU Utilization"
          description: "CPU is at {{ $value | printf \" %.2f \"}} for more than 10 mins"
```


## Alertmanager

I have downloaded the alertmanager and manually created the systemd unit file with following content
```conf
[Unit]
Description=Alert manager for prometheus

[Service]
User=alertmanager
Group=alertmanager
ExecStart=/usr/local/bin/alertmanager --config.file=/etc/alertmanager/alertmanager.yml --storage.path=/var/lib/alertmanager
Restart=always

[Install]
WantedBy=multi-user.target
~                            
```


I have created a service account with name alertmanager using `sudo useradd -r -s /usr/sbin/nologin alertmanager` command

Also I have placed the config inside /etc/alertmanager directory and created a directory /var/lib/alertmanager for alertmanager to store the data.

As alertmanager is running on port 9093 I have configured the prometheus to send alerts to alertmanager using below config

```yml
alerting:
  alertmanagers:
    - static_configs:
        - targets: ['localhost:9093']
```



## PromQL queries

1. Write a PromQL query that calculates the percentage of free memory available on your Linux host.

`(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100`


2. Write a PromQL query that shows the rate of disk reads (bytes per second) over the last 5 minutes.

`rate(node_disk_read_bytes_total[5m])`