#!/bin/bash
tmux new-session -d -s ftmain -n myWindow
tmux send-keys -t ftrecv:myWindow "cd /mnt/nfs/pacescript/ssh_check" Enter
tmux send-keys -t ftrecv:myWindow "./start_select_node.sh" Enter

