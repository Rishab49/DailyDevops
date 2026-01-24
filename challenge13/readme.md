# Challenge 13: The Infrastructure Auditor (Security Benchmark)

Scenario: We have a Load Balancer, Web Server, and Database. Now we need to ensure the entire OS is hardened according to industry standards.

Task Requirements:

Linux Admin (Bucket A): Research and identify 3 "CIS Benchmark" style hardening steps for a Linux server (e.g., disabling unused filesystems, setting password complexity, or restricting cron access).

Implement one of these manually (e.g., restricted cron access using /etc/cron.allow).

Shell Logic (Bucket C): Update your audit.sh (from Challenge 10) to include:

A check for empty passwords in /etc/shadow.

A check for any non-root users with UID 0.

Orchestration (Bucket B): Configure your SSH Daemon (/etc/ssh/sshd_config) to:

Disable Root Login.

Disable Password Authentication (Force SSH Keys only).

Set a Login Grace Time of 1 minute.

Success Criteria:

Submit the updated audit.sh snippet.

Submit the modified lines from sshd_config.

Explain why "Root Login" should be disabled even if you have a strong password.



# Solution

## Restrict cron access to users

In order to restrict a user from acccessing crontab we need to do one of the following
1. We can create a cron.allow file inside /etc and enter the name of users who should be able to access the crontab, other users will be denied the permission
2. Or we can create a cron.deny file inside /etc and add the names of the users whom we donot want to acccess the crontab




## Checking users with empty password 

sudo passwd -Sa | awk -F: '{ if($2 == "NP"){ print $1}}'


## Checking any user with uid 0 other than root

sudo cat /etc/passwd | awk -F: '{if ($3 == 0 && $1 != "root"){printf "User with UID 0 : %s", $1}}'


## Disable Root login

To disable root login we need to update the sshd config located inside /etc/ssh directory

Inside the directory we need to add an entry `PermitRootLogin no` and restart our sshd using `sudo systemctl restart sshd`

Reason: 
- If we disable root login the we cannot accidentally login as root user and execute commands, as we need to explicitly evevate privilege
- If a malicuous user wants to login to system then they have to guess the user first and then guess its password and then hope it is in sudoers list.

## Disable Password authentication

In order to disable password authentication we need to make the following changes to the config
1. Add an entry `PasswordAuthentication no`, this disables the password authentication
2. Add another entry `KbdInteractiveAuthentication no`, this disables the prompt and response methods which are used as alternative to passwords.



## To enforce only key based login

We need to add the above entries and along with that we need to add following
1. `PubKeyAuthentication yes`, this enables the key authentication


