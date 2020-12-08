#!/bin/bash
##host=cujuft@cujuft-machine2
##monitor=/home/cujuft/vm1r.monitor
host=$1
monitor=/tmp/vm1r.monitor
##################################
cuju_command=cuju-get-ft-mode

output=$(./ssh_connect_backupvm_return_varible.sh $host | grep "RANDOM:" | awk '{print $2}'|grep -o '^[0-9]\+')

if [ $? -eq 0 ];  then
    ##echo "Backup VM running result: $?"
    echo "$output"
fi

exit $output


