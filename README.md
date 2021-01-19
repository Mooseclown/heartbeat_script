----
Title : Auto script for Cuju 
----
## 說明
標題包含[P]: 表示於Primary下操作
標題包含[B]: 表示於Backup下操作

共5步
1. 設定host名稱
2. 修改environment.sh
3. 設定corosync.conf
4. 安裝script
5. 產生ssh key並複製到另一端

## 1. 修改成sudo時不需要密碼 [P/B]
```shell
$ sudo visudo
[your username] ALL=(ALL) NOPASSWD: ALL
```
並做以下測試
```shell
sudo su [your username]
```
## 2. 設定host名稱 [P/B]
```shell
$sudo vim /etc/hosts

10.0.2.4 cujuft-machine1
10.0.2.5 cujuft-machine2
```

## 3. 下載 auto script [P/B]
```shell
git clone https://github.com/kester-lin/heartbeat_script.git
cd heartbeat_script
```

## 4. 設定environment.sh [P/B]
```shell
primary_name=cujuft
backup_name=cujuft
primary_host=cujuft-machine1
backup_host=cujuft-machine2
vmp_monitor=/home/cujuft/vm1.monitor
vmb_monitor=/home/cujuft/vm1r.monitor
external_ip=192.168.110.183
```


## 5. 新增設定檔 [P/B]
sudo vi corosync.conf

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
## 6. 安裝 auto script [P/B]
```shell
cd heartbeat_script
sudo ./install.sh
```
## 7. ssh-keygen [P/B]
```shell
ssh-keygen
ssh-copy-id [cujuft-machine1/cujuft-machine2]
```

### auto script 檔案說明 [P/B]
下載本頁面的的專案後得到8個主要檔案
`FailOverScript`:為Packmaker Failover module
`failover.sh`:為Pacemaker切換後執行的shell script 目前為寫入時間至log中
`install.sh`:為自動安裝Packmaker Failover module的shell script
`clearlog.sh`:清除log檔
`show.sh`:印出log檔
`environment.sh`:各項環境變數
`setup_corocync.sh`:設定corosync script
`reservice.sh`:重新啟動pacemaker/corosync service

```shell
$cd heartbeat_script 
$ls -al
-rwxr-xr-x 1 ft ft   94 Sep  6 11:05 clearlog.sh
-rwxr-xr-x 1 ft ft 5340 Sep  6 13:42 FailOverScript
-rwxrwxrwx 1 ft ft  139 Sep  6 12:46 failover.sh
-rwxrwxr-x 1 ft ft  189 Sep  6 13:15 install.sh
-rwxr-xr-x 1 ft ft  105 Sep  6 13:31 show.sh
```

### 確認Pacemaker狀態 [P/B]
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

### 發生Failover後 
```shell
$cd heartbeat_script
$sudo ./show.sh

start

Script Up at Fri Sep  6 14:47:38 CST 2019

```
