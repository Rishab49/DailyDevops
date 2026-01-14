# Challenge 08: The Local Monitor (Grafana & Persistence)

Scenario: Management wants a visual dashboard. Since we are avoiding expensive cloud services, we will host our own monitoring stack on your Free Tier EC2.

Task Requirements:

Linux Admin (Bucket A): Download and install Prometheus (the binary, not Docker) on your Linux server.

Create a dedicated user for it: sudo useradd --no-create-home --shell /bin/false prometheus.

Configure Prometheus to scrape the Node Exporter you set up in Challenge 06.

Observability (Bucket D): Install Grafana (OSS version).

Configure a local data source in Grafana pointing to your Prometheus instance (localhost:9090).

Shell Logic (Bucket C): Create a script health_check.sh.

This script should run via a Cron Job every 5 minutes.

It should use curl to check if the Grafana login page is reachable (200 OK).

If it's not reachable, it should send an email (or append a "CRITICAL" entry to /var/log/sysadmin.log if an email agent isn't set up).


# Solution

prometheus.yml

I have created a configuration file for prometheus to scrape the node exporter which I have installed in challenge 6 and upon start it runs on port 9100 so I have configured the same in file using `static_configs: - targets: ["localhost:9100"]`. 

We can start the prometheus using `prometheus --config.file=<PATH_TO_CONFIG>`

```yaml
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "nodeexporter"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9100"]
       # The label name is added as a label `label_name=<label_value>` to any timeseries scraped from this config.
        labels:
          app: "nodeexporter"
```

One more thing which I learnt is that we can update/reload the prometheus config using `curl -X POST http://localhost:9090/-/reload` command and for this to work lifecycle api needs to be enabled `--web.enable-lifecycle` 

health_check.sh

I have created the health check script which checks whether grafana dashboard is accessible or not using curl command I have specifically used `-sI` flag so that the output which I get is only the response headers and also it is silient and I donot get any loaders in output, then I grepped the line containing the HTTP and later inside if block I am check whther the HTTP line has 200 OK or not if yes I am printing success otherwise I am logging to sysadmin.log using logger which I setup in previous challenge.

```sh
#!/bin/bash

HTTP_STATUS=$(curl -sI http://localhost:300/login | grep -i "HTTP")

if [[ "$HTTP_STATUS" == *"200 OK"* ]]; then
    echo "SUCCESS"
else
    logger -p local0.emerg "Grafana dashboard is not reachable"
fi
```


