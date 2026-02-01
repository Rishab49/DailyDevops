# Challenge 12: The Database & Persistence (MySQL/MariaDB)

Scenario: A web server and a load balancer are great, but most apps need a database. We need to install, secure, and monitor a database on your Linux instance without using RDS (to keep it Free Tier).

Task Requirements:

Linux Admin (Bucket A): Install MariaDB or MySQL server.

Security (Bucket B): * Run the mysql_secure_installation script logic (manually or via script).

Create a dedicated database app_db and a user app_user that can only connect from localhost.

Logic Constraint: Use a strong password and ensure the user only has SELECT, INSERT, UPDATE permissions (not DROP or DELETE).

Observability (Bucket D):

Configure your monitor.sh to check if the database process is running.

Advanced: Write a small script db_check.sh that attempts to log in and run SELECT 1;. If it fails, log a critical error.

Shell Logic (Bucket C):

Create a cron job that performs a Daily Logical Backup using mysqldump.

Pipe the output to gzip and store it in your backup directory (which is already being synced to S3 by your Challenge 09 script).


# Solution

In order to complete this challenge I did following


## Installation

I have installed mysql using dnf.


## DB and user creation

I have created a new db using `create database app_db;` command and then created a new user using `create user 'app_user'@'localhost' identified by '<PASSWORD>'` and as new users do not have any permissions we need to grant permission to the user using `grant select, insert, update privilege on app_db.* to 'app_user'@'localhost'`


## Monitor.sh

I have updated the monitoring script with following block which will check if mysql is running or not and if it is not running then it will try to start it

```bash
NGINX_EXIT_CODE=$(sudo systemctl status mysqld)
if [ $? -ne 0 ];then
    echo "MYSQL is not started."
    echo "Attempting to start it"
    sudo systemctl start mysqld
else
    echo "MYSQL is in running state"
fi
```


## db_check.sh

I have created one script which will login to mysql using `.my.cnf` file located in home directory and then execute a command using `-e` flag. It is a best practice to use `.my.cnf` file to login to mysql in script rather than exposing them.

`mysql -e "SELECT 1;" > /dev/null`


## backup.sh
 
 I have created on another script inside which I am taking backup of mysql using `mysqldump` command and here also I am logging into mysqldump using same `.my.cnf` file so that I donot expose the username and password.


```
[mysqldump]
user=root
password=password


[mysql]
user=root
password=password
```

I am taking backup of all of the databases using the below command and routing the output to an sql file which I am zipping so that we can upload it to s3 bucket.


`mysqldump --all-databases > $filename`





