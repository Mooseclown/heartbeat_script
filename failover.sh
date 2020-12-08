#!/bin/bash
#################### Control Variable ####################
LOCAL_PWD=`pwd`
cd /mnt/nfs/pacescript
. ./environment.sh

echo "$LOCAL_PWD"
cd $LOCAL_PWD
##primary_host=cujuft-machine1
##backup_host=cujuft-machine2
##vmp_monitor=/home/cujuft/vm1.monitor
##vmb_monitor=/home/cujuft/vm1r.monitor
##external_ip=192.168.110.183
##external_ip=192.168.125.5

# 1 is check hostname method, 2 is check the status of qemu monitor
script_vsersion=2
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
run_ruby () {
	if [ $local_machine == $primary_host ]; then 
		echo "[Run Ruby] ftp_machine1"|tee -a  /var/log/failover/script
		####ruby /usr/local/bin/ftp_machine1.rb
		ruby /mnt/nfs/pacescript/ftp_machine1.rb
	else
		echo "[Run Ruby] ftp_machine2"|tee -a  /var/log/failover/script
		####ruby /usr/local/bin/ftp_machine2.rb
		ruby /mnt/nfs/pacescript/ftp_machine2.rb
	fi
		echo "=============================="|tee -a  /var/log/failover/script
}
close_run_ruby () {
	if [ $local_machine == $primary_host ]; then 
		echo "[Run Close Ruby] ftp_machine2"|tee -a  /var/log/failover/script
		####ruby /usr/local/bin/ftp_machine2.rb
		ruby /mnt/nfs/pacescript/ftp_machine2.rb
	else
		echo "[Run Close Ruby] ftp_machine1"|tee -a  /var/log/failover/script
		####ruby /usr/local/bin/ftp_machine1.rb
		ruby /mnt/nfs/pacescript/ftp_machine1.rb
	fi
		echo "=============================="|tee -a  /var/log/failover/script
}

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

	echo "Monitor is $monitor"|tee -a  /var/log/failover/script
}

wait_remote (){
	ssh_host=$($local_user@)
	bash /mnt/nfs/pacescript/ssh_check/check_bhost_start_bvm.sh $remote_host $remote_monitor
}

primary_nop () {
	echo "Primary nop"|tee -a  /var/log/failover/script
	close_run_ruby
}

backup_nop () {
	echo "Backup nop"|tee -a  /var/log/failover/script
	close_run_ruby
}

primary_close () {
	echo "Primary Close"|tee -a  /var/log/failover/script
	sudo echo "quit" | sudo nc -U $monitor
	close_run_ruby
}

backup_close () {
	echo "Backup Close"|tee -a  /var/log/failover/script
	sudo echo "quit" | sudo nc -U $monitor
	close_run_ruby
}

primary_back_noft () {
	echo "Primary Go to NOFT"|tee -a  /var/log/failover/script
	sudo echo "cuju-migrate-cancel" | sudo nc -U $monitor
	run_ruby
        cd /mnt/nfs/pacescript/ssh_check
        sudo su $local_user tmux_remote_node.sh
}

backup_failover () {
	echo "Backup Failover"|tee -a  /var/log/failover/script
	sudo echo "cuju-failover" | sudo nc -U $monitor
	run_ruby
        cd /mnt/nfs/pacescript/ssh_check
        sudo su $local_user tmux_remote_node.sh
}

backup_have_failovered () {
	cuju_backup_status_result=0
	
	cuju_backup_status=$(sudo echo "cuju-get-ft-mode" | sudo nc -U $monitor | grep "cuju_ft_mode:" | awk '{print $2}'|grep -o '^[0-9]\+')
	
	if [ $cuju_backup_status == "5" ]; then 
		cuju_backup_status_result=1
		echo "RESULT: $cuju_backup_status_result in ft recv mode" |tee -a  /var/log/failover/script
	else
		echo "RESULT: $cuju_backup_status_result not in recv mode" |tee -a  /var/log/failover/script
	fi
}

pingtest () {
	ext_result=1		
	####ping -c 3 -w 1 $external_ip  &> /dev/null && ext_result=0 || ext_result=1
	fping -i 10 -p 20 -q -c3 $external_ip  &> /dev/null && ext_result=0 || ext_result=1
}

check_cuju_exist () {
	cuju_exist_primary_result=0
	cuju_exist_backup_result=0
	cuju_primary_exist=0
	cuju_backup_exist=0
	local_ft_started=0
	
	cuju_primary_exist=$(sudo echo "cuju-get-ft-started" | sudo nc -U $monitor)
	
	local_ft_started=$(echo "cuju-get-ft-started" | sudo nc -U $monitor |grep "ft_started:" | awk '{print $2}'|grep -o '^[0-9]\+')

	if [ $local_ft_started == "1" ]; then 
		echo "Cuju Primary in FT mode"|tee -a  /var/log/failover/script
		cuju_exist_primary_result=1
		return 0
	else
		echo "Cuju Primary not in FT mode"|tee -a  /var/log/failover/script
		cuju_exist_primary_result=0
	fi		

	backup_have_failovered
	if [ $cuju_backup_status_result == "1" ]; then
		echo "Cuju Backup in FT recv mode"|tee -a  /var/log/failover/script
		cuju_exist_backup_result=1
	else
		echo "Cuju Backup not in FT recv mode"|tee -a  /var/log/failover/script
		cuju_exist_backup_result=0
	fi
}

failover_start () {
	check_cuju_exist

	if [ $local_machine == $backup_host -a $cuju_exist_backup_result == "1" ]; then
		echo "[Backup]  $local_machine"
		pingtest
		
		if [ "$ext_result" -eq "0" ]; then
			echo "[Backup] Machine $external_ip is Up."
			backup_failover
		else
			echo "[Backup] Machine $external_ip is DOWN."
		fi
	fi
  
	if [ $local_machine == $primary_host -a $cuju_exist_primary_result == "1" ]; then
		echo "[Primary]  $local_machine"
		pingtest
		
		if [ "$ext_result" -eq "0" ]; then
			echo "[Primary] Machine $external_ip is Up."
			echo "[Primary] Go back to NoFT mode (Currently using Close)"
			primary_back_noft
		else
			echo "[Primary] Machine $external_ip is DOWN."
			primary_close
		fi 
	fi
}

failover2_start () {
	whichmonitor
	check_cuju_exist

	if [ $cuju_exist_backup_result == "1" ]; then
		echo "[Backup]  $local_machine"|tee -a  /var/log/failover/script
		pingtest
		
		if [ "$ext_result" -eq "0" ]; then
			echo "[Backup] Machine $external_ip is Up."|tee -a  /var/log/failover/script
			backup_failover
		else
			echo "[Backup] Machine $external_ip is DOWN."|tee -a  /var/log/failover/script
			backup_nop
			
		fi
	fi
  
	if [ $cuju_exist_primary_result == "1" ]; then
		echo "[Primary]  $local_machine"|tee -a  /var/log/failover/script
		pingtest
		
		if [ "$ext_result" -eq "0" ]; then
			echo "[Primary] Machine $external_ip is Up."|tee -a  /var/log/failover/script
			echo "[Primary] Go back to NoFT mode"
			primary_back_noft
		else
			echo "[Primary] Machine $external_ip is DOWN."|tee -a  /var/log/failover/script
			primary_nop
		fi 
	fi
}

upSeconds="$(cat /proc/uptime | grep -o '^[0-9]\+')"
echo $upSeconds

upHalfMins=$((${upSeconds} / 30))

if [ "${upHalfMins}" -gt "1" ]; then
    echo "Up for ${upHalfMins} half minutes"
        echo "Script Up at $(date)" |tee -a  /var/log/failover/script

	####backup_have_failovered
	if [ $script_vsersion == "1" ]; then 
		failover_start
	else
		failover2_start
	fi
else
    echo "Uptime less than 1 min."
fi



