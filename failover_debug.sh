#!/bin/bash
upSeconds="$(cat /proc/uptime | grep -o '^[0-9]\+')"
echo $upSeconds

upHalfMins=$((${upSeconds} / 30))

if [ "${upHalfMins}" -gt "1" ]; then
    echo "Up for ${upHalfMins} half minutes"
    echo "Script Up at $(date)" |tee -a  /var/log/failover/script
else
    echo "Uptime less than 1 min." |tee -a /var/log/failover/script
fi



