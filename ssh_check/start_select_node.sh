#/bin/bash
LOCAL_PWD=`pwd`
cd /mnt/nfs/pacescript
. ./environment.sh

echo "$LOCAL_PWD"
cd $LOCAL_PWD
##primary_name=cujuft
##backup_name=cujuft
##primary_host=cujuft-machine1
##backup_host=cujuft-machine2
##vmp_monitor=/home/cujuft/vm1.monitor
##vmb_monitor=/home/cujuft/vm1r.monitor

##primary_name=ubuntu
##backup_name=ubuntu
##primary_host=4U8-1
##backup_host=4U8-2
##local_machine=`hostname`
##vmp_monitor=/tmp/vm1.monitor
##vmb_monitor=/tmp/vm1r.monitor
local_machine=`hostname`
#==========================================================
remote_monitor=
monitor=
remote_host=
local_host=
local_name=
remote_name=
#==========================================================

wait_vm_ready () {
primaryvm_ready=1
backupvm_ready=1
sleep_time=0

while [ $primaryvm_ready != 0 -o $backupvm_ready != 0 ];
do
    #echo "check primary vm ready? ./check_primaryvm.sh $local_host $monitor" 
    primaryvm_ready=$(./check_primaryvm.sh $local_host $monitor| grep "result:"| awk '{print $5}')
        echo "$primaryvm_ready"

    #echo "check backup vm ready? ./check_backupvm.sh $remote_host $remote_monitor"
    backupvm_ready=$(./check_backupvm.sh $remote_host $remote_monitor| grep "result:"| awk '{print $5}')
        echo "$backupvm_ready"

    #echo "Priamry VM is $primaryvm_ready"
    #echo "Backup VM is $backupvm_ready"

        if [ $primaryvm_ready != 0 ]; then
                #echo "Primary VM NOT ready"
                sleep_time=`expr $sleep_time + 5`
        else
                echo "Primary VM Ready"
        fi

        if [ $backupvm_ready != 0 ]; then
                #echo "Backup VM NOT ready"
                sleep_time=`expr $sleep_time + 5`
        else
                echo "Backup VM Ready"
        fi

        #echo "Retry after sleep $sleep_time"
        sleep $sleep_time
        sleep_time=0
done
}

disk_recovery () {
    bash /mnt/nfs/gluster_heal.sh
    bash /mnt/nfs/diskfsck.sh
    sleep 3
}

run_ftmode () {
    echo "Start FT mode "
    sleep $reboot_time
    cd /mnt/nfs
    ./ftmode.sh    
}

run_primary_vm () {
    echo "Start Primary VM at $local_host $monitor"
    ./tmux_runvm.sh
}

run_backup_vm () {
    echo "Start Backup VM at $remote_host"
    ./check_bhost_start_bvm.sh $remote_host $remote_monitor
}

whichmonitor () {
	if [ $local_machine == $primary_host ]; then
	remote_host=$backup_host
        local_host=$primary_host
        local_name=$primary_name
        remote_name=$backup_name
	monitor=$vmp_monitor
        remote_monitor=$vmb_monitor
	else
	remote_host=$primary_host
        local_host=$backup_host
        local_name=$backup_name
        remote_name=$primary_name
	monitor=$vmb_monitor
        remote_monitor=$vmp_monitor
	fi
}

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
show_environment
whichmonitor

##local_random=`expr $RANDOM % 100 + 1`
##echo "RANDOM: $local_random" | sudo tee /tmp/local_random
##cat /tmp/local_random
local_random=$(cat /tmp/local_random | grep "RANDOM:" | awk '{print $2}'|grep -o '^[0-9]\+')
echo "local: $local_random"

##echo $local_random
echo "===== Get Remote Varible ====="
re='^[0-9]+$'
get_value=1 
while [ $get_value != 0 ];
do
    ##remote_random=$(./check_remote_random.sh $remote_name@$remote_host | grep "RANDOM:" | awk '{print $2}'|grep -o '^[0-9]\+')
    remote_random=$(./check_remote_random.sh $remote_name@$remote_host)

    echo "remote: $remote_random"
    if [ -n $remote_random ]; then
	echo "TRUE: $remote_random"
	
	if ! [[ $remote_random =~ $re ]]
        then
	    echo "Not a number"
	    continue
	fi
        
	if [ $remote_random -gt 0 ]; then
            echo "remote: $remote_random"
	    echo "TRUE: $remote_random"
	    get_value=0
        fi
    else 
	echo "FALSE: $remote_random"
    fi
done

if [ $local_random -eq $remote_random ]; then
    echo "$primary_host run as primaty"
    if [ $local_machine == $primary_host ]; then
        disk_recovery
        run_primary_vm
        run_backup_vm
	wait_vm_ready
        run_ftmode
    fi
fi

if [ $local_random -gt $remote_random ]; then
    echo "local > remote run as primaty"
    disk_recovery
    run_primary_vm
    run_backup_vm
    wait_vm_ready
    run_ftmode
else
    echo "local < remote"
fi

