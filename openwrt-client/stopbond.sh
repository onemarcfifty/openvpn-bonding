#!/bin/bash

# #############################################
#
# stopbond.sh
#
# disconnects the VPN,
# removes the tap devices 
# and the bond interface
#
# #############################################

# include the common settings
. /etc/openvpn/commonConfig

# shut down and delete the bonded interface

ip link set $bondInterface down
ip link del $bondInterface

# disconnect the VPN connections and remove the tap interfaces

killall openvpn

for i in `seq 1 $numberOfTunnels`;
do
#    systemctl stop openvpn-client@client${i}.service

    ip route del default table "vpn$i"
    ip rule del table "vpn$i"
    openvpn --rmtun --dev tap${i}
done

echo "please up/down your default interface to restore routes etc"