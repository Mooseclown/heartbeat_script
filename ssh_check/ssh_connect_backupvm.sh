#!/usr/bin/expect

set timeout 5

set host [lindex $argv 0]
set monitor [lindex $argv 1]
set command [lindex $argv 2]

spawn ssh $host -p 22

expect {
    "nc: unix connect failed: Connection refused" {send "echo $command |sudo nc -w 1 -U $monitor\r\r"; sleep 1;exp_continue}
    "Connection refused" {exit 1}
    "Name or service not known" {exit 2}
    "Connection timed out" {exit 3}    
    "No route to host" {exit 4}    
    "continue connecting" {send "yes\r";exp_continue}
    "password:" {send "$pw\r";exp_continue}
    "Last login" {send "echo $command |sudo nc -w 1 -U $monitor\r"; exp_continue}
    "cuju_ft_mode: 1" {send "ifconfig\r"; exit 0}
    "cuju_ft_mode: 0" {send "echo $command |sudo nc -w 1 -U $monitor\r\r"; exp_continue}
    "No such file or directory" {send "echo $command |sudo nc -w 1 -U $monitor\r\r"; sleep 1;exp_continue}

} 

expect eof
exit 5

