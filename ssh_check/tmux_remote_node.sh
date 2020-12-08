#!/bin/bash
tmux new-session -d -s ftrecovery -n myWindow
tmux send-keys -t ftrecovery:myWindow "cd /mnt/nfs/pacescript/ssh_check" Enter
tmux send-keys -t ftrecovery:myWindow "./start_remote_node.sh" Enter
tmux send-keys -t ftrecovery:myWindow "exit" Enter

###tmux attach -t ftrun:myWindow
##sleep 10
##tmux new-session -d -s ftmode_check -n myWindow
##tmux send-keys -t ftmode_check:myWindow "cd /mnt/nfs/pacescript/ssh_check/" Enter
##tmux send-keys -t ftmode_check:myWindow "./check.sh" Enter

