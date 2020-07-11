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

# now add the routing tables

for i in `seq 1 $numberOfTunnels`;
do

    # first read out the interface name from the config section

    tunnelInterface="tunnelInterface$i"
    echo "###########################################"
    echo "adding routing table vpn${i}"
    echo Tunnel Interface $i is ${!tunnelInterface}

    # we need to find the ip address of this interface

    tunnelInterfaceIP=""



openvpn --config /etc/openvpn/tap0.conf
ip route add 192.168.10.0/24 dev eth1 scope link table dsl1
ip route add default dev ppp0 table dsl1
ip rule add pref 10 from 192.168.10.0/24 table dsl1

openvpn --config /etc/openvpn/tap1.conf
ip route add 192.168.11.0/24 dev eth2 scope link table dsl2
ip route add default dev ppp1 table dsl2
ip rule add pref 11 from 192.168.11.0/24 table dsl2

ip route flush cache

ip link add bond0 type bond
ip addr add 10.80.0.2/30 dev bond0

ip link set tap0 master bond0
ip link set tap1 master bond0

ip link set bond0 up mtu 1440

/usr/local/bin/gw bond0



done
echo "###########################################"


# then start the VPN connections

for i in `seq 1 $numberOfTunnels`;
do
    systemctl start openvpn-client@client${i}.service
done

# last but not least bring up the bonded interface

ip link set $bondInterface up mtu 1440
