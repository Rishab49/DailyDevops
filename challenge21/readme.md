# Challenge 21: The Schema Showdown (Loki vs. Elasticsearch)
Scenario: Management is considering switching from Loki to ELK because they want "Full-Text Search" capabilities. You need to demonstrate the difference between Loki's index-free approach and ELK's document-indexing approach.

Task Requirements:
Linux Admin (Bucket A): The Lightweight Shipper

Install Filebeat (the "lite" version of Logstash) on your server.

Create a systemd unit for it.

Orchestration (Bucket B): The Dual-Pipe

Configure filebeat.yml to harvest the same Nginx logs you are currently sending to Loki.

Instead of sending to a real Elasticsearch (to save RAM), configure the output to console or a local file /tmp/filebeat_output.json.

Use the Filebeat Nginx Module to automatically parse the logs into structured JSON.

Observability (Bucket D): Comparison Table

Create a comparison table between Promtail and Filebeat.

Focus on: Resource usage, ease of configuration, and how they handle "Parsing" (Hint: One parses at the source, the other usually lets the DB handle it).

Logic (Bucket C): The "Grok" Challenge

Logstash and Filebeat use "Grok patterns." Write a Grok pattern that would extract the request_method (GET/POST) and the request_path from this standard Nginx line: 127.0.0.1 - - [08/Feb/2026:10:30:47 +0000] "GET /api/v1/users HTTP/1.1" 200


# Solution


## Filebeat

I have installed filebeat by downloading the tar file and then extracting the executable and placing it at `/usr/local/bin` folder. Then I created a directory to store the config files and store the persistent data if filebeat, after that I have created a systemd unit file with below config.

```yaml
[Unit]
Description= Log collector

[Service]
User=filebeat
Group=filebeat
ExecStart=/usr/local/bin/filebeat -c /etc/filebeat/filebeat.yml --path.data=/etc/filebeat --path.home=/etc/filebeat --path.logs=/etc/filebeat
Restart=always

[Install]
WantedBy=multi-user.target
```
## Filebeat vs promtail


| Filebeat | Promtail |
|-----------|-----------|
| Filebeat is created for elastic stack but it can send data anywhere | Promtail can only send data to loki |
| Filebeat is lightweight | promtail is also lightweight |
| Filebeat does do much of log parsing it happens at the destination using logstash etc. | promtail do to most of log parsing and send the data to loki |
| Filebeat uses modules to parse some technologies hence it is easier to setup | In promtail we need to manually write the pipeline to parse the logs |




## Grok pattern

We can use the following grouk pattern to extract the request_apth and request_method
`%{IP} - - \[%{HTTPDATE}\] \"%{WORD:request_method} %{DATA:request_path} %{DATA}\"`

