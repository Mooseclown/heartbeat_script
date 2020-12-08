#!/bin/bash
tmux new-session -d -s ftrun -n myWindow
tmux send-keys -t ftrun:myWindow "cd /mnt/nfs" Enter
tmux send-keys -t ftrun:myWindow "./gluster_heal.sh" Enter
tmux send-keys -t ftrun:myWindow "./runvm.sh" Enter

###tmux attach -t ftrun:myWindow
##sleep 10
##tmux new-session -d -s ftmode_check -n myWindow
##tmux send-keys -t ftmode_check:myWindow "cd /mnt/nfs/pacescript/ssh_check/" Enter
##tmux send-keys -t ftmode_check:myWindow "./check.sh" Enter

