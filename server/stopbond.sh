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

# just kill all openvpn instances

kill `pidof openvpn`

for i in `seq 1 $numberOfTunnels`;
do
#    systemctl stop openvpn-server@server${i}.service
    openvpn --rmtun --dev tap${i}
done
