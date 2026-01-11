# Challenge 06: The "Zero-Cost" Linux Hardening & Monitoring
We are moving away from EKS. We will use a single Free Tier EC2 (t2.micro) or your Local Linux environment.

Scenario: You have a Linux server running a critical web app. You need to automate the security and monitor the performance without using expensive managed services.

Task Requirements:

- Shell Scripting (Bucket C): Write a Bash script monitor.sh that:

    Checks if nginx is running. If not, try to restart it.

    Calculates Disk Usage. If it's over 80%, send a log message to /var/log/sysadmin.log.

    Finds the top 5 processes consuming the most memory and saves them to a daily report file.

- Web Server (Bucket B): * Configure nginx to serve a static page, but implement Basic Auth (username/password) so it's not open to the world.

    Set up a custom log_format in Nginx to capture the "Response Time" of requests.

- Observability (Bucket D): * Instead of a managed service, install Node Exporter manually on the Linux host (no Docker).

    Write a systemd unit file (node_exporter.service) to ensure it starts automatically on boot.



# Solution

## Shell Script(Monitor.sh)

I have created the script monitor.sh which does following

- It checks whether nginx is running or not, if not it attempts to start it.

    It does that by using the exit code of the `sudo systemctl status nginx`, if this command returns 0 it means nginx is running and if not then it means nginx is not running and it attempts to start it.


- It also check the utilization of all of the mount points and sends a message to sysadmin.log if any of the mount point is above 80%
    It does this by using the df -h command and then using awk on the output to get the mount point and its utilization percentage and then using while loop to iterate over each line and check the utilization percentage using `if (( ))` if utilization is higher than 80 then it logs a message to sysadmin.log file which is configured using rsyslog config
 
- It also maintains a log file of top resource comsuming processes

    It does this by piping top command though head and tail respectively to get the top 5 processes and output the value to a log file.


## Web Server configuration

To confgure the we server to display webpage only after authentication i used the following resource, in short it uses the `htpasswd` utility to create a username and password entry inside `/etc/nginx/` and then configuring the nginx server config block with `auth_basic_user_file` to use the generated .htpasswd file for authentication.

https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/

```conf

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    log_format response_log '$remote_addr - $request_time';

    access_log  /var/log/nginx/access.log  main;



    sendfile            on;
    tcp_nopush          on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;
        index index2.html;

        location / {

        auth_basic "Authentication required to view the site";
        auth_basic_user_file /etc/nginx/.htpasswd;
        }


        access_log /var/log/nginx/response.log response_log;
        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;
    }
}

```


## Observability

The challenge asks us to create a systemd unit file which will start the node_exporter and also configure the exporter manually.

Configuring nodeexporter is very straight forward, we just need to download the zip file extract it and run the script.

Same we have done inside the nodeexporter.service file we have just provided the node_exporter file path and it will automatically start it when we start the system using `systemctl enable nodeexporter.service` or start if right now using `systemctl start nodeexporter.service`

```conf
[Unit]
Description=Node exporter
After=network.target

[Service]
ExecStart=/usr/local/bin/node_exporter
Restart=always
User=raj
#WorkingDirectory=/path/to/your/project

[Install]
WantedBy=multi-user.target
```