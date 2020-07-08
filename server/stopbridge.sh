#!/bin/bash

# #############################################
#
# stopbridge.sh
#
# removes the tap devices 
# and the bridge
# make sure you have bridge-utils installed
# (apt install bridge-utils)
#
# #############################################

# include the common settings
. /etc/openvpn/commonConfig

ifconfig $bridgeInterface down
brctl delbr $bridgeInterface

for i in `seq 1 $numberOfTunnels`;
do
    systemctl stop openvpn-server@server${i}.service
    openvpn --rmtun --dev tap${i}
done
