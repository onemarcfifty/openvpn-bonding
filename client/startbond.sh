#!/bin/bash

# #############################################
#
# startbond.sh
#
# creates multiple tap devices
# and bonds them together
#
# #############################################

# include the common settings
. /etc/openvpn/commonConfig

# load the required module

modprobe bonding

# create the bonding interface

ip link add $bondInterface type bond

# assign it the bondIP

ip addr add ${bondIP}/24 dev $bondInterface

# now create the tap interfaces and enslave them to 
# the bond interface

for i in `seq 1 $numberOfTunnels`;
do
    openvpn --mktun --dev tap${i}
    ip link set tap${i} master $bondInterface
done

# then start the VPN connections

for i in `seq 1 $numberOfTunnels`;
do
    systemctl start openvpn-client@client${i}.service
done

# last but not least bring up the bonded interface

ip link set $bondInterface up mtu 1440
