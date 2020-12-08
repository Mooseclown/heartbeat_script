#!/bin/bash
##host=cujuft@cujuft-machine2
##monitor=/home/cujuft/vm1r.monitor
host=$1
##monitor=$2
##################################
cuju_command=cuju-get-ft-mode

output=$(./ssh_connect_backup_host.sh $host)

if [ $? -eq 0 ];  then
    echo "remote hoat connected result: $?"
else
    echo "remote host disconnected result: $?"
fi
exit $? 


