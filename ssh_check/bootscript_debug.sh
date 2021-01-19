#!/bin/bash
cd /mnt/nfs/heartbeat_script
. ./environment.sh

tmux new-session -d -s ftmain -n myWindow
tmux send-keys -t ftrecv:myWindow "cd $prefix_folder/ssh_check" Enter
tmux send-keys -t ftrecv:myWindow "./start_select_node.sh" Enter

