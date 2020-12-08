#!/bin/bash

#cuju_monitor_variable=$(cat /etc/profile|grep CUJU_MONITOR)
#if [ -z "$cuju_monitor_variable" ]; then
#    echo "export CUJU_MONITOR=" | sudo tee -a /etc/profile
#fi 

#cuju_monitor_stop_variable=$(cat /etc/profile|grep CUJU_MONITOR_STOP)
#if [ -z "$cuju_monitor_stop_variable" ]; then
#    echo "export CUJU_MONITOR_STOP=" | sudo tee -a /etc/profile
#fi

#source /etc/profile
. ./environment.sh
local_machine=`hostname`

show_environment () {
echo "==================environment=================="
echo "primary name $primary_name"
echo "backup name $backup_name"
echo "primary host $primary_host"
echo "backup host $backup_host"
echo "primary home $primary_home"
echo "backup home $backup_home"
echo "vmp_monitor $vmp_monitor"
echo "vmb_monitor $vmb_monitor"
echo "external_ip $external_ip"
echo "boot_time $boot_time"
echo "reboot_time $reboot_time"
echo "reconnect_time $reconnect_time"
echo "==============================================="
}



copybootscripttohome () {
show_environment
	if [ $local_machine == $primary_host ]; then 
		echo "Copy bootscript.sh to home folder"
		cp -a bootscript.sh $primary_home
	else
		echo "Copy bootscript-r.sh to home folder"
		cp -a bootscript-r.sh $backup_home
	fi
}

if [ -f "usr/sbin/corosync" ];then
    echo "find pacemaker/corosync exist"
else
    echo "No pacemaker/corosync application, install it"
    sudo apt install -y pacemaker libxml2-utils
fi

if [ -f "/usr/bin/fping" ];then
    echo "find fping exist"
else
    echo "No fping application, install it"
    sudo apt install -y fping 
fi

if [ -f "/usr/bin/expect" ];then
    echo "find expect exist"
else
    echo "No expect application, install it"
    sudo apt install -y expect 
fi

if [ -d "/var/log/failover" ]; then
    echo "Directory /var/log/failover exists."
else
    echo "Directory /var/log/failover does not exists."
    mkdir -p /var/log/failover
fi
	
 
if [ -f "/var/log/failover/log" ]; then
    echo "File /var/log/failover/log exists."
else
    echo "/var/log/failover/log does not exists. and create it"
    touch /var/log/failover/log
    chmod 777 /var/log/failover/log
fi


if [ -f "/var/log/failover/script" ]; then
    echo "File /var/log/failover/script exists."
else
    echo "/var/log/failover/scriopt does not exists. and create it"
    touch /var/log/failover/script
    chmod 777 /var/log/failover/script
fi

if [ -d "/var/log/failover" ]; then
    echo "failover log folder existed"
else
    echo "create failover log folder"
    mkdir -p /var/log/failover
fi


sudo cp -a corosync.conf /etc/corosync/
##sudo cp -a failover.sh /usr/local/bin/
##sudo cp -a environment.sh /usr/local/bin/
##sudo cp -a ftp_machine1.rb /usr/local/bin/
##sudo cp -a ftp_machine2.rb /usr/local/bin/
sudo cp -a FailOverScript /usr/lib/ocf/resource.d/heartbeat/

ocf-tester -n resourcename /usr/lib/ocf/resource.d/heartbeat/FailOverScript

copybootscripttohome

sudo ./reservice.sh
sudo ./setup_corosync.sh
sleep 3
sudo ./reservice.sh
