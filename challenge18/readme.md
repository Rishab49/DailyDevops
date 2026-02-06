# Challenge 18: The Log Aggregator (Loki & Promtail)

Scenario: Metrics tell you when the server is slow, but logs tell you why. You’ve been parsing logs with awk and grep (great for Level 3!), but now we need a central place to view logs alongside our metrics. We’ll use the "Prometheus for Logs"—Grafana Loki.

Task Requirements:
Linux Admin (Bucket A): The PLG Stack

Download the Loki and Promtail binaries (Free Tier, no Docker).

Create a systemd unit for both.

Orchestration (Bucket B): Promtail Scraping

Configure promtail.yml to scrape two specific log files:

/var/log/nginx/access.log

/var/log/secure (or /var/log/auth.log depending on your OS).

Add a label called job: "nginx" for the web logs and job: "system" for the auth logs.

Logic (Bucket C): LogQL

In the Grafana "Explore" tab, how would you write a LogQL query to find all lines in your Nginx logs that contain a 404 status code?

How would you write a query to count the number of failed SSH attempts over the last hour?



# Solution

I have created 2 service accounts `promtail` and `loki` and created 2 directories `/etc/promtail` and `/etc/loki` to store their configs and created sysstemd unit files with following config

```yaml
[Unit]
Description=Log aggregator for loki


[Service]
User=promtail
Group=promtail
ExecStart=/usr/local/bin/promtail -config.file=/etc/promtail/promtail-local-config.yaml
Restart=always

[Install]
WantedBy=multi-user.target


```


```yaml
[Unit]
Description=Log collector for grafana

[Service]
User=loki
Group=loki
ExecStart=/usr/local/bin/loki -config.file=/etc/loki/loki-local-config.yaml
Restart=always

[Install]
WantedBy=multi-user.target

```

# promtail.config

I used the following config to create 2 targets which targets the nginx logs and access.log

```yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://localhost:3100/loki/api/v1/push

scrape_configs:
- job_name: system
  static_configs:
  - targets:
      - localhost
    labels:
      job: system
      __path__: /var/log/secure

- job_name: nginx
  static_configs:
  - targets:
      - localhost
    labels:
       job: nginx
       __path__: /var/log/nginx/access.log

```

# LogQL

We can use the following query to get the count of failed SSH attempts over last hour
`count_over_time({job="system"} |= `Failed password` [1h])`

We can use the following query to find all lines in your nginx logs that contains 404
`{job="nginx"} |= `404``