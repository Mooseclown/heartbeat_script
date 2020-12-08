#!/bin/bash
LOCAL_PWD=`pwd`
cd /mnt/nfs/pacescript
. ./environment.sh

if [ -e $vmp_monitor ]; then
      rm -rf $vmp_monitor
fi

if [ -e $vmb_monitor ]; then
      rm -rf $vmb_monitor
fi

echo "$LOCAL_PWD"
cd $LOCAL_PWD

sleep $boot_time
sudo mount -t glusterfs FTGlusterFS2:/gvol0 /mnt/nfs
sync

sudo /usr/sbin/openvpn --mktun --dev tap0 --user `id -un`
sudo ifconfig tap0 promisc up
sudo brctl addif br0 tap0

sudo /usr/sbin/openvpn --mktun --dev tap1 --user `id -un`
sudo ifconfig tap1 promisc up
sudo brctl addif br0 tap1

#$local_random=`expr $RANDOM % 100 + 1`
local_random=1
echo "RANDOM: $local_random" | sudo tee /tmp/local_random

tmux new-session -d -s ftmain -n myWindow
tmux send-keys -t ftmain:myWindow "cd /mnt/nfs/pacescript/ssh_check" Enter
tmux send-keys -t ftmain:myWindow "./start_select_node.sh" Enter
tmux send-keys -t ftmain:myWindow "exit" Enter


