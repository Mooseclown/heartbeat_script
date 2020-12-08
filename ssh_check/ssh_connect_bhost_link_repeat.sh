#!/usr/bin/expect

set timeout 60

set pw "cujuft"
set host [lindex $argv 0]

spawn ssh $host -p 22

expect {
    "nc: unix connect failed: Connection refused" {send "bash /mnt/nfs/pacescript/ssh_check/tmux_backvm_start.sh\r"; sleep 1; exit 0}
    "nc: unix connect failed: No such file or directory" {send "bash /mnt/nfs/pacescript/ssh_check/tmux_backvm_start.sh\r"; sleep 1; exit 0}
    "Connection refused" {exit 1}
    "Name or service not known" {exit 2}
    "Connection timed out" {exit 3}    
    "No route to host" {exit 4}    
    "continue connecting" {send "yes\r";exp_continue}
    "password:" {send "$pw\r";exp_continue}
    "Last login" {send "sudo ip link set eno1 down\r"; sleep 10; send "sudo ip link set eno1 up"; exit 0}

} 

expect eof
exit 5

