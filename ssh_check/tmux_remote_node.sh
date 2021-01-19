#!/bin/bash
tmux new-session -d -s ftrecovery -n myWindow
tmux send-keys -t ftrecovery:myWindow "cd $prefix_folder/ssh_check" Enter
tmux send-keys -t ftrecovery:myWindow "./start_remote_node.sh" Enter
tmux send-keys -t ftrecovery:myWindow "exit" Enter


