# Challenge 10: The Automated SRE (Security & Patching)
Scenario: To complete Level 3, you must demonstrate "Self-Healing" capabilities. Your server needs to stay updated and secure without manual intervention.

Task Requirements:

Linux Admin (Bucket A): Configure Unattended Upgrades (on Ubuntu/Debian) or dnf-automatic (on Amazon Linux/RHEL).

Set it to automatically download and install Security Updates only.

Shell Logic (Bucket C): Create a "Security Audit" script audit.sh.

It must check for World-Writable files in /home and /etc and log them to /var/log/security_audit.log.

It must list all Failed SSH Login attempts from the last 24 hours (hint: check /var/log/secure or /var/log/auth.log).

Observability (Bucket D):

Update your monitor.sh (from Challenge 06) to now also check if the Prometheus and Node Exporter services are active. If they are down, the script should try to restart them.

Success Criteria:

Submit the audit.sh script.

Submit the configuration line for dnf-automatic or unattended-upgrades (specifying security only).

Submit the updated service-check logic for monitor.sh.

# Solution

## dnf automatic

dnf-automatic/ unattended upgrades are linux packages which are used to automatically download and install upgrades on linux system.

In RHEL based system we have dnf-automatic but in debian based systems we have unattended upgrades

we can install it in RHEL using `dnf install dnf-upgrade` and check whether it got installed or not using `rpm -qi dnf-automatic`

There are four modes in which we can run this package
- Download the available updates(`systemctl enable --npw dnf-automatic-download.timer`)
- Download and install the available updates(`systemctl enable --now dnf-automatic-install.timer`)
- Report available updates(`systemctl enable --now dnf-automatic-notifyonly.timer`)
- Do all three of above.(`systemctl enable --timer dnf-automatic.timer`)

In order to download and update the security updates only we need to update the /etc/dnf/automatic.conf file with `upgrade_type = security` and then run `systemctl --now enable dnf-automatic-install.timer`



## audit.sh

Inside this script file i am executing the find command to find all of the files and then executing the stat command to get the filename along with its permission in human readable format using the below command

```bash
ETC_WORLD_WRITABLES=$(find /etc -maxdepth 2 -type f  -exec stat -c "%A %n" {} + 2> /dev/null)
```

after that I am using awk command on the output of find commandto extract the write permission of other users and then checking it whether it is equal to "w" or not and if it is then it indicates the file is world redable.

then I am making a log entry inside security_audit.log file using below command

```bash
echo "$ETC_WORLD_WRITABLES" | awk '{
    permission=substr($1,9,1)
    printf "%s",permission
    if (permission == "w") { 
    system(" logger -p local0.warn \"The file " $2 " is world writable\" ")
      print $0
    } 
}'
```

for logging i have created a separate log entry inside the rsyslog config to redirect all of the local0.* log to /var/log/security_audit.log


# Service restart attempt

Also i have updated the monitor.sh script to restart prometheus and nodeexporter as well if it is down using below snippet