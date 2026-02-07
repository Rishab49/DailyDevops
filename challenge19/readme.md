# Challenge 19: The Log Parser (Pipeline Stages)

Scenario: Currently, your logs are just "strings." To build a real dashboard (like a pie chart of status codes), Loki needs to "extract" data from those strings into labels. We do this using Pipeline Stages in Promtail.

Task Requirements:
Orchestration (Bucket B): The Regex Stage

Update your promtail.yml for the nginx job.

Add a pipeline_stages section using the regex stage to extract the status code and the remote IP address from the Nginx access log.

Nginx logs usually look like: 127.0.0.1 - - [06/Feb/2026...] "GET / HTTP/1.1" 200 ...

Observability (Bucket D): 

Use the labels stage within that same pipeline to turn the extracted status_code into a real Loki label.

Warning: Don't turn the IP address into a label! (Interview Tip: Why is putting high-cardinality data like IPs into Loki labels a bad idea for your t2.micro?)

Logic (Bucket C): Advanced LogQL

Once the status code is a label, write a LogQL query that calculates the percentage of requests that resulted in an error (status codes 4xx or 5xx) over the last 15 minutes.



# Solution


## promtail.yaml

I have updated the promtail config with pipeline_stages that includes regex stage and labels stage 

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
  pipeline_stages:
    - regex:
        expression: '^(?s)(?P<IP>\S+).*?" (?P<Status>\d+)'
    - labels:
        Status:


```



## LogQL

I have used the following LogQL query to that 

`count_over_time({Status=~"5..|4..", job="nginx"} [15m]) / count_over_time({job="nginx"} [15m]) * 100`