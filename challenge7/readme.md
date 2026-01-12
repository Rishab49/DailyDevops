# Challenge 07: The Log Master (Log Rotation & Parsing)

Scenario: Your Nginx server is getting popular. The response.log file you created is growing too fast and will eventually fill up the disk. You need to manage these logs and extract insights.

Task Requirements:

Linux Admin (Bucket A): Configure logrotate for your custom Nginx logs (/var/log/nginx/*.log).
:
Rotate them daily.

Keep only 7 days of history.

Compress old logs to save space.

Shell Automation (Bucket C): Create a script analyze_logs.sh.

It must read the response.log file.

Calculate the Average Response Time of all requests in the file.

Identify the top 3 slowest requests.

Security (Bucket B): * Write a one-liner command or a small script that parses access.log and lists the top 10 IP addresses that have attempted to access your site (checking for brute-force attempts on your Basic Auth).


# Solution

In this challenge I did following

- Updated logrotate.d/nginx 

    ```log
    /var/log/nginx/*.log {
        create 0640 nginx root
        daily
        rotate 7
        missingok
        notifempty
        compress
        delaycompress
        sharedscripts
        postrotate
            /bin/kill -USR1 `cat /run/nginx.pid 2>/dev/null` 2>/dev/null || true
        endscript
    }
    ```

    In the above script we have configured the logrotate to daily rotate the logs `daily`, keep logs which are at most 7 days old `rotate 7`, if current log file is missing do not throw any error `missingok`, compress the old log files but donot compress the current one `compress` and after log rotation run send USR1 signal to nginx which tells it to use the new log file instead of the old one 
    ```log
    postrotate
            /bin/kill -USR1 `cat /run/nginx.pid 2>/dev/null` 2>/dev/null || true
    endscript
    ```

- Wrote a bash script file which calculates the average response time of nginx respones and identifies the top 3 slowest response

    My bash script is simple first it takes all of the response times from the access.log file
    `RESPONSE_TIMES=$(awk '{print $3}' /var/log/nginx/response.log)`

    Then Identify the slowest response from it using the below command
    `SLOWEST_PROCESS=$(echo "$RESPONSE_TIMES" | sort -n | tail -n 3)`

    Then it uses the awk command to calculate the average response time
    `AVERAGE_RESPONSE_TIME=$(awk 'BEGIN{sum=0; count=0} {sum += $3; count++} END {printf sum/count}' /var/log/nginx/response.log)`

    lastly we are pritning our findings

- Write a one line command which parses the access.log and list the top 10 ip addressess that have attempted to access sites

    I have used the awsk command to take all of the ip addresses and used sort | uniq -c command to sort them and them calculate the frequency of each IP address. Lastly I am using awk command to print the top 10 IP addresses 
    `awk '{print $1}' /var/log/nginx/access.log-20260112 | sort | uniq -c | tail -n 10 | awk '{printf "The IP %s accessed the site %s time\n", $2, $1}'`