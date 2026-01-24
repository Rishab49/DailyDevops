#!/bin/bash

HOME_WORLD_WRITABLES=$(find /home -maxdepth 2 -type f  -exec stat -c "%A %n" {} + 2> /dev/null)
ETC_WORLD_WRITABLES=$(find /tmp -maxdepth 2 -type f  -exec stat -c "%A %n" {} + 2> /dev/null)
echo "$HOME_WORLD_WRITABLES" | awk '{
    permission=substr($1,9,1)
    printf "%s\n",permission
    if (permission == "w") { 
    system(" logger -p local0.warn \"The file " $2 " is world writable\" ")
    print $0
    } 
}'


echo "$ETC_WORLD_WRITABLES" | awk '{
    permission=substr($1,9,1)
    printf "%s",permission
    if (permission == "w") { 
    system(" logger -p local0.warn \"The file " $2 " is world writable\" ")
      print $0
    } 
}'

# current user is in sudo group but still it will ask for password because the directory /var/log/secure does not have any permission for group and others
sudo grep "Failed password" /var/log/secure

# echo "$HOME_WORLD_WRITABLES"


# Checking if any user exist with No password or empty password

sudo passwd -Sa | awk -F" " '{ if($2 == "NP"){ print $1} else{printf ""}}'

# Checking if we have users with uid 0 other than root user
sudo cat /etc/passwd | awk -F: '{if ($3 == 0 && $1 != "root"){print "User with UID 0 : %s", $1}}'




