# Challenge 20: The Observability Unified (Final Capstone)
Scenario: You have the metrics (Prometheus) and the logs (Loki). Now, you need to provide a single "Single Source of Truth" dashboard for the engineering team that correlates the two.

Task Requirements:
Observability (Bucket D): Correlation

In Grafana, create a Dashboard Link or a Data Link.

Configure it so that when you look at a "CPU Spike" in a Prometheus graph, you can click it and it takes you to the Loki logs for that exact same time window and instance. (Describe the steps to do this).

Linux Admin (Bucket A): Resource Constraints

Since you are running Prometheus, Grafana, Loki, Promtail, Node Exporter, and Nginx on one t2.micro (1GB RAM), you are at high risk of a crash.

Use Systemd Resource Limits (MemoryLimit) in your unit files to ensure that if Loki starts eating too much RAM, the OS kills it before it takes down the whole server.

Update one of your service files (e.g., loki.service) to include a 512M memory limit.

Shell Logic (Bucket C): The "Self-Healer" V2

Update your monitor.sh script to now check the health of the Loki API.

It should query http://localhost:3100/ready.

If it doesn't return ready, restart the service and send a log to /var/log/sysadmin.log.



# Solution

## Data link

To add data link in grafana I followed following steps



1. First I created the loki dashboard with a particular job name
2. Then i copied the URL of the dashboard after saving it
3. Then I created a dashboard with cpu data of different instances with following query
`rate(node_cpu_seconds_total{mode="idle"}[5m]) * 100`
4. Then I Changed the unit to percent
5. After that in the right panel of the dashboard inside the datalink panel I clicked on add data link button
6. then i added a new data with the following url, where I updated the from value with a variable which can change according to the point where we have clicked in the graph.
`http://localhost:3000/d/adw6fsl/loki-logs?orgId=1&from=${__value.time}&to=now&timezone=browser`
7. Then i saved the dashboard



## Resource constraint

I have added the following line in loki.service file to restrict its max memory under the `[Service]` section

```service
MemoryMax=512M
```


## monitor.sh

I have added the following snippet of code to monitor.sh

```sh
LOKI=$(curl -s http://localhost:3100/ready)

if [ "$LOKI" == "ready" ]; then
    echo "loki is up and running fine"
else
    echo "restarting loki"
fi
```

