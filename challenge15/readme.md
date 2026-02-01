# Challenge 15: The "Production-Ready" Web Stack (Final Capstone)

Scenario: You have been promoted to a Senior DevOps Engineer. Your task is to build a fully automated, 3-tier web architecture on your Linux server. This combines everything you have learned.

Task Requirements:

Orchestration (Bucket B): Use Ansible to deploy:

HAProxy (Frontend) listening on Port 80.

Two Nginx Instances (Backends) on Ports 8081 and 8082.

MariaDB/MySQL (Database) on Port 3306.

Logic (Bucket C): Create a Python Script app_check.py that:

Queries the HAProxy stats socket (via socat) to see which backends are "UP".

Attempts to connect to the Database.

Prints a JSON status report: {"load_balancer": "OK", "database": "OK", "active_nodes": 2}.

Observability (Bucket D):

Set up a Grafana Dashboard (manual screenshot or description) that shows a graph of "Failed SSH Logins" (from your Challenge 10 audit.sh data).

Security (Bucket A):

Ensure all database backups (from Challenge 12) are encrypted using gpg before being uploaded to S3.

Success Criteria:

Submit the site.yml (Master Ansible Playbook).

Submit the app_check.py logic.

Submit the gpg command used to encrypt the backup.

# Solution

## Ansible playbook(deploy.yml)

I have created one playbook which ensures the required packages i.e; haproxy, mysql and nginx is installed, enabled and started. using the below config

```yml
 - name: Make sure packages are installed
    ansible.builtin.yum:
      name: "{{ item }}"
      state: present
    loop:
      - mysql-community-server
      - nginx
      - haproxy
  - name: Make sure packages are enabled and installed
    ansible.builtin.systemd:
      name: "{{ item }}"
      enabled: true
      state: started
    loop:
      - nginx
      - mysqld
      - haproxy
```


In the same config I am configuring the nginx and haproxy by copying the readymade config from current directory to the respective config location.

```yml
 - name: Configuring nginx
    ansible.builtin.copy:
      src: ./lb.conf
      dest: /etc/nginx/conf.d/lb.conf
      owner: root
      group: root
      mode: "0644"
  - name: Configuring HAPROXY
    ansible.builtin.copy:
      src: ./ha.cfg
      dest: /etc/haproxy/conf.d/ha.cfg
      owner: root
      group: root
      mode: "0644"
```


Also I am ensuring in the config that socket is enabled in haproxy config so that we can later check using script whether backends are up and running or not. Also I am using insertbefore option with `^global$` regex so that the if line not present then it will be added under global config

```yml
  - name: Make sure socket is enabled
    ansible.builtin.lineinfile:
      path: /etc/haproxy/haproxy.cfg
      line: "    stats socket /var/lib/haproxy/stats mode 660 level admin"
      insertafter: "^global$"
      state: present
```

## app_check.py

I have created a python script file which will get the current stats from haproxy using `"echo 'show stat rgw' | socat stdio /var/lib/haproxy/stats"` command and then check how many backends are up and if lb and db are up or not and then print then in the below format
```py
result={
    "counter":0,
    "database_status": "NOT OK",
    "lb_status": "NOT OK"
}
```

## audit.sh

I have created a script file which will check all of the failed login attempts and log the count `/var/lib/node_exporter/textfile_collector/ssh_failures.prom` file 

In `system_ssh_failed_ssh_login_counts $output` format, the reason I am logging the data in this file as I have configured nodeexporter to look this path and collect the data using `--collector.textfile.directory=/var/lib/node_exporter/textfile_collector` flag

Which I can visualize using prometheus and grafana later.


## backup.sh

I have created a backup shell script which will take complete backup of sql using `mysqldump` and then encrypts it using gpg and later push to s3 bucket.







