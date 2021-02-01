#!/usr/bin/expect

set timeout 30

set pw ""
set host [lindex $argv 0]
set monitor [lindex $argv 1]
set command [lindex $argv 2]

spawn ssh $host -p 22

expect {
    "nc: unix connect failed: Connection refused" {exit 5}
    "nc: unix connect failed: No such file or directory" {exit 6}
    "Connection refused" {exit 1}
    "Name or service not known" {exit 2}
    "Connection timed out" {exit 3}    
    "No route to host" {exit 4}    
    "continue connecting" {send "yes\r";exp_continue}
    "password:" {send "$pw\r";exp_continue}
    "Last login" {send "echo $command | sudo nc -U $monitor\r"; exp_continue}
    "cuju_ft_mode: 6" {exit 0}
} 

expect eof
exit 7
