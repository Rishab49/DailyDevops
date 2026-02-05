# Challenge 17: The Dashboard Architect (Grafana Variables & Recording Rules)

Scenario: Your monitoring is working, but it’s not "scalable." If you add 10 more servers, you don't want to create 10 more dashboards. You need to make your Grafana dashboard dynamic and optimize Prometheus performance for long-term trends.

Task Requirements:
Observability (Bucket D): Grafana Variables

Describe how you would create a Variable in Grafana (named instance) that automatically populates with all available hostnames/IPs from your Prometheus data.

What PromQL query would you use in the "Query" field of the variable settings to get these names?

Linux Admin (Bucket A): Recording Rules

Some queries (like the CPU percentage calculation) are heavy to calculate every time a dashboard refreshes.

Create a Recording Rule in Prometheus that pre-calculates the CPU usage percentage and saves it into a new metric called job:node_cpu:percent.

Update your alert.rules.yml to use this new metric instead of the long 100 * (1 - ...) formula.

Shell Logic (Bucket C): Automation

Write a script check_prom_config.sh that uses the promtool utility (which comes with Prometheus) to check your configuration and rules files for syntax errors before you reload the service.


# Solution


## Adding a Variable

In order to create a variable in grafana we need to do following

1. Goto the dashbaord
2. Edit it
3. Navigate to the variables section
4. Add a new variable
4. Enter its name and according to type you can have steps futher
5. then exit to dashboard

I have used the following [steps](https://grafana.com/docs/grafana/latest/visualizations/dashboards/variables/add-template-variables/)

## PromQL Query

I have used `label_values(up,instance)` query to get the ip and hostname out of each target

## Recording rules

We can add recording rules in a simple yaml file same as alert rules, I have added the below rules

```yml
groups:
  - name: RecordRule1
    rules:
      - record: job:node_cpu:percent
        expr: 100 * (1 - avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[2m])))
```


## check_prom_config

I have created a shell which uses promtool to check for any error in rules 

```sh
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
```

