#!/bin/bash
host=$1
monitor=$2
##################################
cuju_command=cuju-get-ft-mode

output=$(./ssh_connect_remote.sh $host $monitor $cuju_command)

if [ $? -eq 0 ];  then
    echo "Remote VM running result: $?"
else
    echo "Remote VM closed result: $?"
fi
exit $?