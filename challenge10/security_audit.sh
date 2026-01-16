#!/bin/bash

HOME_WORLD_WRITABLES=$(find /home -maxdepth 2 -type f  -exec stat -c "%A %n" {} + 2> /dev/null)
ETC_WORLD_WRITABLES=$(find /etc -maxdepth 2 -type f  -exec stat -c "%A %n" {} + 2> /dev/null)
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


sudo grep "Failed password" /var/log/secure

# echo "$HOME_WORLD_WRITABLES"