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

wait_remote_host () {
remote_host_ready=1
remote_sleep_time=0
    echo "Try to connect to remote host $remote_host" |sudo tee -a /var/log/failover/ft
    while [ $remote_host_ready != 0 ];
    do
        remote_host_ready=$(./check_remote_host.sh $remote_host |grep "result:" | awk '{print $5}')
        echo "Ready? $remote_host_ready" | sudo tee -a /var/log/failover/ft
        if [ $remote_host_ready != 0 ]; then 
            echo "Remote Host NOT ready" | sudo tee -a /var/log/failover/ft
	    remote_sleep_time=`expr $remote_time_sleep + 5`
        else
            echo "Remote Host ready" | sudo tee -a /var/log/failover/ft
        fi

        sleep $remote_sleep_time
        remote_sleep_time=0
    done 

}

wait_vm_ready () {
primaryvm_ready=1
backupvm_ready=1
sleep_time=0

while [ $primaryvm_ready != 0 -o $backupvm_ready != 0 ];
do
    #echo "check primary vm ready? ./check_primaryvm.sh $local_host $monitor" 
    primaryvm_ready=$(./check_primaryvm.sh $local_host $monitor| grep "result:"| awk '{print $5}')
        echo "Primary $primaryvm_ready" | sudo tee -a /var/log/failover/ft

    #echo "check backup vm ready? ./check_backupvm.sh $remote_host $remote_monitor"
    backupvm_ready=$(./check_backupvm.sh $remote_host $remote_monitor| grep "result:"| awk '{print $5}')
        echo "backup $backupvm_ready" | sudo tee -a /var/log/failover/ft

    #echo "Priamry VM is $primaryvm_ready"
    #echo "Backup VM is $backupvm_ready"

        if [ $primaryvm_ready != 0 ]; then
                echo "Primary VM NOT ready" | sudo tee -a /var/log/failover/ft
                sleep_time=`expr $sleep_time + 5`
        else
                echo "Primary VM Ready" | sudo tee -a /var/log/failover/ft
        fi

        if [ $backupvm_ready != 0 ]; then
                echo "Backup VM NOT ready" | sudo tee -a /var/log/failover/ft
                sleep_time=`expr $sleep_time + 5`
        else
                echo "Backup VM Ready" | sudo tee -a /var/log/failover/ft
        fi

        #echo "Retry after sleep $sleep_time"
        sleep $sleep_time
        sleep_time=0
done
}

run_ftmode () {
    echo "Start FT mode" | sudo tee -a /var/log/failover/ft
    sleep $reconnect_time
    cd /mnt/nfs
    ./ftmode.sh    
}

run_primary_vm () {
    echo "Start Primary VM at $local_host $monitor"
    ./tmux_runvm.sh
}

run_backup_vm () {
    echo "Start Backup VM at $remote_host $remote_monitor" | sudo tee -a /var/log/failover/ft
    ./check_bhost_start_bvm.sh $remote_host $remote_monitor
}

whichmonitor () {
    echo "local $local_machine"
    echo "primary $primary_host"

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

whichmonitor 
cd /mnt/nfs/pacescript/ssh_check/
echo "==================== wait_remote_host ====================" | sudo tee -a /var/log/failover/ft
wait_remote_host
echo "==================== run_backup_vm ====================" | sudo tee -a /var/log/failover/ft
run_backup_vm
echo "==================== wait_vm_ready ====================" | sudo tee -a /var/log/failover/ft
wait_vm_ready
echo "==================== run_ftmode ====================" | sudo tee -a /var/log/failover/ft
run_ftmode


