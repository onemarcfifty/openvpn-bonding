#!/bin/bash

# #############################################
#
# startbridge.sh
#
# creates multiple tap devices
# and bridges them
# make sure you have bridge-utils installed
# (apt install bridge-utils)
#
# #############################################

# include the common settings
. /etc/openvpn/commonConfig

brctl addbr $bridgeInterface

for i in `seq 1 $numberOfTunnels`;
do
    openvpn --mktun --dev tap${i}
    brctl addif $bridgeInterface tap${i}
    ifconfig tap${i} 0.0.0.0 promisc up
done

ifconfig $bridgeInterface $bridgeIP netmask 255.255.255.0
# broadcast $bridge_broadcast

# now start the vpn servers

for i in `seq 1 $numberOfTunnels`;
do
    systemctl start openvpn-client@client${i}.service
done



