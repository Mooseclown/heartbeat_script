#!/bin/bash
primaryvm_ready=1
backupvm_ready=1
sleep_time=0

while [ $primaryvm_ready != 0 -o $backupvm_ready != 0 ];
do 
    primaryvm_ready=$(./check_primaryvm.sh | grep "result:"| awk '{print $5}')
	echo "$primaryvm_ready"
	
    backupvm_ready=$(./check_backupvm.sh | grep "result:"| awk '{print $5}')
	echo "$backupvm_ready"
	
    ##echo "Priamry VM is $primaryvm_ready"
    ##echo "Backup VM is $backupvm_ready"
	
	if [ $primaryvm_ready != 0 ]; then
		echo "Primary VM NOT ready"
		sleep_time=`expr $sleep_time + 5` 
	else
		echo "Primary VM Ready"
	fi

	if [ $backupvm_ready != 0 ]; then
		echo "Backup VM NOT ready"
		sleep_time=`expr $sleep_time + 5`
	else
		echo "Backup VM Ready"
	fi

	sleep $sleep_time
	sleep_time=0
done

#######ADD FT script here####### 
cd /mnt/nfs
./ftmode.sh
