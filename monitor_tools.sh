#!/bin/bash
echo "cuju-get-ft-started" | sudo nc -U /home/cujuft/vm1.monitor
echo "cuju-get-ft-mode" | sudo nc -U /home/cujuft/vm1.monitor


LOCAL_PWD=`pwd`
cd /mnt/nfs/heartbeat_script
. ./environment.sh



#################### Result Variable ####################
local_machine=`hostname`
ext_result=1
cuju_exist_primary_result=0
cuju_exist_backup_result=0
ft_enable="1"
remote_monitor=
monitor=
remote_host=
cuju_backup_status_result=0
#################### Function Entry ####################

whichmonitor () {

        if [ $local_machine == $primary_host ]; then
                remote_host=$backup_host
                local_user=$primary_name
        else
                remote_host=$primary_host
                local_user=$backup_name
        fi

        if [ -e $vmp_monitor ]; then
                monitor=$vmp_monitor
                remote_monitor=$vmb_monitor
        fi

        if [ -e $vmb_monitor ]; then
                monitor=$vmb_monitor
                remote_monitor=$vmp_monitor
        fi

        echo "Monitor is $monitor"
}

whichmonitor

local_ft_started=$(echo "cuju-get-ft-started" | sudo nc -U $monitor)
echo "Show FT statred: $local_ft_started"

local_ft_started=$(echo "cuju-get-ft-started" | sudo nc -U $monitor | grep "ft_started:" )
echo "Show FT statred: $local_ft_started"

local_ft_started=$(echo "cuju-get-ft-started" | sudo nc -U $monitor | grep "ft_started:" | awk '{print $2}')
echo "Show FT statred: $local_ft_started"

local_ft_started=$(echo "cuju-get-ft-started" | sudo nc -U $monitor | grep "ft_started:" | awk '{print $2}'| grep -o '^[0-9]\+')
echo "Show FT statred: $local_ft_started"
