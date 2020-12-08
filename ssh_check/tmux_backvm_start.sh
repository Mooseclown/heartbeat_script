#!/bin/bash
tmux new-session -d -s ftrecv -n myWindow
tmux send-keys -t ftrecv:myWindow "cd /mnt/nfs" Enter
tmux send-keys -t ftrecv:myWindow "./recv.sh" Enter
##tmux attach -t ftrecv:myWindow
