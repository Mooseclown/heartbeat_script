#!/bin/bash
echo "when using link repeat test script, everything should be configure for the real environment"

select_node=0
node_count=2
cont_idx=1

node_1=1
node_2=2


###################################################
node_1_down () {
sudo ip link set enp4s0 down
}
node_1_up () {
sudo ip link set enp4s0 up
}


echo "start link up and down repeat test"

while [ $cont_idx != 0 ];
do

    idx_now=$(($select_node % $node_count))
    idx_now=`expr $idx_now + 1`
    ##idx_now=`expr $idx_now`
    echo "select node $idx_now"


    if [ $idx_now == $node_1 ]; then
    	echo "$idx_now: action" 
        node_1_down
        sleep 10
	node_1_up
	
    fi

    if [ $idx_now == $node_2 ]; then
    	echo "$idx_now: action" 
        ./ssh_connect_bhost_link_repeat.sh 192.168.123.101
    fi

 
    sleep 300

    select_node=`expr $select_node + 1`

done
