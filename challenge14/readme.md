# Challenge 14: The Automation of Configuration (Ansible Lite)
Scenario: Manually editing /etc/ssh/sshd_config or /etc/cron.allow is fine for one server, but what if you had 10? We need to move toward Configuration as Code. Since we are staying Free Tier, we will use Ansible (which is agentless and costs $0).

Task Requirements:

Linux Admin (Bucket A): Install Ansible on your EC2 instance (it will act as both the control node and the managed node).

Orchestration (Bucket B): Write a simple Ansible Playbook (hardening.yml) that:

Ensures nginx and mariadb are started and enabled.

Copies a custom index.html to /usr/share/nginx/html/.

Ensures the file /etc/ssh/sshd_config has PermitRootLogin no (use the lineinfile module).

Shell Logic (Bucket C):

Create a script check_drift.sh.

This script should run the Ansible playbook in --check mode (dry run).

If Ansible finds "changed" items (meaning someone manually changed a config file), it should log a "DRIFT DETECTED" warning to /var/log/sysadmin.log.

Success Criteria:

Submit the hardening.yml playbook.

Submit the check_drift.sh script logic.

Explain the benefit of "Idempotency" in Ansible.


# Solution

## hardening.yml

The challenge asked us to create an ansible playbook with following
1. It needs to ensure nginx and maridb is started and enabled for that I have used the below task 

```yaml
- name: Starting and enabling services
    ansible.builtin.systemd:
      name: "{{ item }}"
      enabled: yes
      state: started
    loop:
      - nginx
      - mysqld
```

In the above config we are using systemd module of ansible and making sure the looped items i.e; nginx and mysqld are enabled and their state is started

2. Copies a custom index.html to /usr/share/nginx/html/
For this I am using the builtin copy module of ansible

```yaml
  - name: Copy file
    ansible.builtin.copy:
      src: ./index.html
      dest: /usr/share/nginx/html/index.html
      owner: root
      group: root
```


3. Ensuring /etc/ssh/sshd_config has PermitRootLogin no
For this I am using `lineinfile` module and storing the result of the whole task in `config_check_result` variable so that I can use it in upcoming steps
```yaml
- name: Ensure 
    lineinfile:
      path: /etc/ssh/sshd_config
      line: "PermitRootLogin no"
      regexp: '^PermitRootLogin'
      state: present
    become: true
    register: config_check_result
```


4. Logging message to sysadmin.log if the config file is changed

For this I am using the `config_check_result` variable from previous step and then checking if `changed` property of variable is true or not, if it is true then I am executing the logging command `logger -p local5.warn "DRIFT DETECTED"`

```yaml
  - name: Log if changed
    ansible.builtin.shell: logger -p local5.warn "DRIFT DETECTED"
    when: config_check_result.changed
    check_mode: false
```

I am running the command in non check mode explicitly as when I am using while running the command incheck mode ansible will not run the shell command y default


## check_drift.sh
I am using the below command inside the script file to run the ansible in check mode and if we have config drift then we are logging it
`ansible-playbook -i hosts hardening.yml -u ansible --become -K --check --diff`


## Explain the benefit of "Idempotency" in Ansible.

Idempotency of ansible is very important as it allows the us to achieve the following
- Predectibility : Same result on multiple server
- Flexibility: No matter in how many servers we are going to excute the script we will get the same result