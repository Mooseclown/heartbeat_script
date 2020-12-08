----
Title : Pacemaker/Corosync 服務使用 Ubuntu 16.04
----
參考網址:https://raymii.org/s/tutorials/Corosync_Pacemaker_-_Execute_a_script_on_failover.html

## 說明
標題包含[P]: 表示於Primary下操作
標題包含[B]: 表示於Backup下操作

## 安裝Pacemaker [P/B]
sudo apt install -y pacemaker libxml2-utils fping
(corosync於安裝pacemaker時自動安裝)

## 設定host名稱 [P/B]
```shell
$sudo vim /etc/hosts

10.0.2.4 cujuft-machine1
10.0.2.5 cujuft-machine2
```

### [P]
```shell
$sudo vi /etc/hostname

cujuft-machine1
```
### [B]
```shell
$sudo vi /etc/hsotname 

cujuft-machine2
```

## 新增設定檔 [P/B]
sudo vi /etc/corosync/corosync.conf
bindnetaddr: 為網域
ring0_addr:node 各自的address
name: node 各自的hostname
```shell
totem {
  version: 2
  cluster_name: debian
  secauth: off
  transport:udpu
  interface {
    ringnumber: 0
    bindnetaddr: 10.0.2.0
    broadcast: yes
    mcastport: 5405
  }
}

nodelist {
  node {
    ring0_addr: 10.0.2.4
    name:  cujuft-machine1
    nodeid: 1
  }
  node {
    ring0_addr: 10.0.2.5
    name:  cujuft-machine2
    nodeid: 2
  }
}

quorum {
  provider: corosync_votequorum
  two_node: 1
  wait_for_all: 1
  last_man_standing: 1
  auto_tie_breaker: 0
}
```
## pacemaker script [P/B]
可用sudo crm status看見雙方node

## 解壓縮pacemaker script [P/B]
下載本頁面的的專案後得到5個檔案
`FailOverScript`:為Packmaker Failover module
`failover.sh`:為Pacemaker切換後執行的shell script 目前為寫入時間至log中
`install.sh`:為自動安裝Packmaker Failover module的shell script
`clearlog.sh`:清除log檔
`show.sh`:印出log檔

```shell
$cd pacescript 
$ls -al
-rwxr-xr-x 1 ft ft   94 Sep  6 11:05 clearlog.sh
-rwxr-xr-x 1 ft ft 5340 Sep  6 13:42 FailOverScript
-rwxrwxrwx 1 ft ft  139 Sep  6 12:46 failover.sh
-rwxrwxr-x 1 ft ft  189 Sep  6 13:15 install.sh
-rwxr-xr-x 1 ft ft  105 Sep  6 13:31 show.sh
```

## 安裝自動義pacemaker module [P/B] 
與解壓縮後進入其目錄 
安裝pacemaker module FailOverScript
```shell
$cd pacescript
$sudo ./install.sh
```

## 設定pacemaker [P]
```shell
$sudo crm configure 

property stonith-enabled=false 
rsc_defaults resource-stickiness="100"
property no-quorum-policy="ignore"
commit

primitive script ocf:heartbeat:FailOverScript op monitor interval="200ms"
commit

exit 
```

## 確認Pacemaker狀態 [P/B]
```shell
$sudo crm status

[sudo] password for cujuft:
Last updated: Sat Oct  5 17:03:37 2019          Last change: Sat Oct  5 15:14:09 2019 by root via cibadmin on cujuft-machine1
Stack: corosync
Current DC: cujuft-machine1 (version 1.1.14-70404b0) - partition with quorum
2 nodes and 3 resources configured

Online: [ cujuft-machine1 cujuft-machine2 ]

Full list of resources:

 script (ocf::heartbeat:FailOverScript):        Started cujuft-machine2

 ```

## 發生Failover後 
```shell
$cd pacescript
$sudo ./show.sh

start

Script Up at Fri Sep  6 14:47:38 CST 2019

```
