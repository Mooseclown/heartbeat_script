#!/bin/bash
host=$1
monitor=$2
##################################
cuju_command=cuju-get-ft-mode

output=$(./ssh_connect_backupvm.sh $host $monitor $cuju_command)

if [ $? -eq 0 ];  then
    echo "Backup VM running result: $?"
else
    echo "Backup VM closed result: $?"
fi
exit $?

