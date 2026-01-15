# Challenge 09: The Backup Strategist (Data Integrity)
Scenario: Your Grafana and Prometheus configurations are getting complex. If the EC2 instance fails, you will lose all your dashboards and settings. You need a reliable backup strategy.

Task Requirements:

Shell Logic (Bucket C): Write a script backup_configs.sh.

It should create a compressed tarball (.tar.gz) containing:

/etc/nginx/ (Nginx configs)

/etc/prometheus/ (Prometheus configs)

/var/lib/grafana/grafana.db (This is where your Grafana dashboards are stored).

The filename must include the current date (e.g., backup_2026-01-14.tar.gz).

Linux Admin (Bucket A): * Ensure the script can only be run by a user in the sudo group.

Use find within your script to delete backups older than 30 days so the disk doesn't fill up.

Infra (Bucket A):

Use the AWS CLI within your script to upload the resulting tarball to an S3 Bucket (Free Tier).

Safety Check: Do not hardcode credentials. Ensure the EC2 instance has an IAM Role with S3PutObject permissions.

# Solution


I have correctly configured the prometheus and grafana.

One thing I learnt in this challenge is that separating the files in their designated folder makes our lives easier, for examples
- keeping executable inside /usr/local/bin such as prometheus, promtool, grafana-server etc.
- keeping configuration inside /etc such as prometheus.yml or grafana.ini inside the respective folder
- keeping the data inside /var/lib such as prometheus or grafana data files


I have created a script which creates backup of nginx and prometheus config and grafana data in form of a tar using the below snippet

```bash
NGINX_CONF=$(ls -d /etc/nginx 2>/dev/null)
PROM_CONF=$(ls -d /etc/prometheus 2>/dev/null)
GRAFANA_CONF=$(ls -d /etc/grafana 2>/dev/null)
GRAFANA_DATA=$(ls -d /var/lib/grafana/grafana.db 2>/dev/null)

DATE=$(date +'%Y-%m-%d')
FILENAME=$(echo "backup_$DATE.tar.gz")

tar -czf $FILENAME $NGINX_CONF $PROM_CONF $GRAFANA_CONF $GRAFANA_DATA 2>/dev/null
```


after creating the tarball I am checking whether the backup was successful or not, if backup was successful then uploading it to s3 using the below snippet


```bash
if [[ $? -ne 0 ]];then
    echo "failed to create tar backup hence cannot uploadto s3"
fi

# Uploading backup
aws s3 cp $FILENAME s3://rajrishab-backup
```


Before executing the script I am checking whther the user belongs to sudo group or not as mentioned in the challenge using below snippet
```bash
if ! id -nG "$USER" | grep -qw "sudo"; then
    echo "Error: This script can only be executed by members of the 'sudo' group."
    exit 1
fi
```


I have also created the below s3 policy which I have attached to EC2 the role which EC2 instance will assume. In the following policy I have allowed the user to upload data to paricular s3 bucket.

```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Statement1",
			"Effect": "Allow",
			"Action": [
				"s3:PutObject"
			],
			"Resource": [
				"arn:aws:s3:::backup"
			]
		}
	]
}
```