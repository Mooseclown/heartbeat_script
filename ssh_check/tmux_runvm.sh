#!/bin/bash
tmux new-session -d -s ftrun -n myWindow
tmux send-keys -t ftrun:myWindow "cd /mnt/nfs" Enter
#tmux send-keys -t ftrun:myWindow "./gluster_heal.sh" Enter
tmux send-keys -t ftrun:myWindow "./runvm.sh" Enter


