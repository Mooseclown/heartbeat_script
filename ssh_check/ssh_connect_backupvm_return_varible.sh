#!/usr/bin/expect

set timeout 15
set host [lindex $argv 0]
##set monitor [lindex $argv 1]
##set command [lindex $argv 2]

spawn ssh $host -p 22

expect {
    "Connection refused" {exit 0}
    "Name or service not known" {exit 0}
    "Connection timed out" {exit 0}    
    "No route to host" {exit 0}    
    "continue connecting" {send "yes\r";exp_continue}
    ##"password:" {send "$pw\r";exp_continue}
    "Last login" {send "cat /tmp/local_random\r";exp_continue}
    "RANDOM: 10" {exit 10}
    "RANDOM: 11" {exit 11}
    "RANDOM: 12" {exit 12}
    "RANDOM: 13" {exit 13}
    "RANDOM: 14" {exit 14}
    "RANDOM: 15" {exit 15}
    "RANDOM: 16" {exit 16}
    "RANDOM: 17" {exit 17}
    "RANDOM: 18" {exit 18}
    "RANDOM: 19" {exit 19}
    "RANDOM: 20" {exit 10}
    "RANDOM: 21" {exit 21}
    "RANDOM: 22" {exit 22}
    "RANDOM: 23" {exit 23}
    "RANDOM: 24" {exit 24}
    "RANDOM: 25" {exit 25}
    "RANDOM: 26" {exit 26}
    "RANDOM: 27" {exit 27}
    "RANDOM: 28" {exit 28}
    "RANDOM: 29" {exit 29}
    "RANDOM: 30" {exit 30}
    "RANDOM: 31" {exit 31}
    "RANDOM: 32" {exit 32}
    "RANDOM: 33" {exit 33}
    "RANDOM: 34" {exit 34}
    "RANDOM: 35" {exit 35}
    "RANDOM: 36" {exit 36}
    "RANDOM: 37" {exit 37}
    "RANDOM: 38" {exit 38}
    "RANDOM: 39" {exit 39}
    "RANDOM: 40" {exit 40}
    "RANDOM: 41" {exit 41}
    "RANDOM: 42" {exit 42}
    "RANDOM: 43" {exit 43}
    "RANDOM: 44" {exit 44}
    "RANDOM: 45" {exit 45}
    "RANDOM: 46" {exit 46}
    "RANDOM: 47" {exit 47}
    "RANDOM: 48" {exit 48}
    "RANDOM: 49" {exit 49}
    "RANDOM: 50" {exit 50}
    "RANDOM: 51" {exit 51}
    "RANDOM: 52" {exit 52}
    "RANDOM: 53" {exit 53}
    "RANDOM: 54" {exit 54}
    "RANDOM: 55" {exit 55}
    "RANDOM: 56" {exit 56}
    "RANDOM: 57" {exit 57}
    "RANDOM: 58" {exit 58}
    "RANDOM: 59" {exit 59}
    "RANDOM: 60" {exit 60}
    "RANDOM: 61" {exit 61}
    "RANDOM: 62" {exit 62}
    "RANDOM: 63" {exit 63}
    "RANDOM: 64" {exit 64}
    "RANDOM: 65" {exit 65}
    "RANDOM: 66" {exit 66}
    "RANDOM: 67" {exit 67}
    "RANDOM: 68" {exit 68}
    "RANDOM: 69" {exit 69}
    "RANDOM: 60" {exit 60}
    "RANDOM: 71" {exit 71}
    "RANDOM: 72" {exit 72}
    "RANDOM: 73" {exit 73}
    "RANDOM: 74" {exit 74}
    "RANDOM: 75" {exit 75}
    "RANDOM: 76" {exit 76}
    "RANDOM: 77" {exit 77}
    "RANDOM: 78" {exit 78}
    "RANDOM: 79" {exit 79}
    "RANDOM: 80" {exit 80}
    "RANDOM: 81" {exit 81}
    "RANDOM: 82" {exit 82}
    "RANDOM: 83" {exit 83}
    "RANDOM: 84" {exit 84}
    "RANDOM: 85" {exit 85}
    "RANDOM: 86" {exit 86}
    "RANDOM: 87" {exit 87}
    "RANDOM: 88" {exit 88}
    "RANDOM: 89" {exit 89}
    "RANDOM: 90" {exit 90}
    "RANDOM: 91" {exit 91}
    "RANDOM: 92" {exit 92}
    "RANDOM: 93" {exit 93}
    "RANDOM: 94" {exit 94}
    "RANDOM: 95" {exit 95}
    "RANDOM: 96" {exit 96}
    "RANDOM: 97" {exit 97}
    "RANDOM: 98" {exit 98}
    "RANDOM: 99" {exit 99}
    "RANDOM: 100" {exit 100}
    "RANDOM: 0" {exit 0}
    "RANDOM: 1" {exit 1}
    "RANDOM: 2" {exit 2}
    "RANDOM: 3" {exit 3}
    "RANDOM: 4" {exit 4}
    "RANDOM: 5" {exit 5}
    "RANDOM: 6" {exit 6}
    "RANDOM: 7" {exit 7}
    "RANDOM: 8" {exit 8}
    "RANDOM: 9" {exit 9}
} 

expect eof
exit 0

