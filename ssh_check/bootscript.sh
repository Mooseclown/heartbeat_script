#!/bin/bash

sudo /usr/sbin/openvpn --mktun --dev tap0 --user `id -un`
sudo ifconfig tap0 promisc up
sudo brctl addif br0 tap0

sudo /usr/sbin/openvpn --mktun --dev tap1 --user `id -un`
sudo ifconfig tap1 promisc up
sudo brctl addif br0 tap1

./start_select_node.sh
