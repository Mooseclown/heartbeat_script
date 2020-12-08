#!/bin/bash
sudo crm configure property stonith-enabled=false 
sudo crm configure rsc_defaults resource-stickiness="100"
sudo crm configure property no-quorum-policy="ignore"
sudo crm configure commit

sudo crm configure primitive script ocf:heartbeat:FailOverScript op monitor interval="200ms"
sudo crm configure commit
