#!/bin/bash

# load the required module

modprobe bonding

# delete bonding interface and kill openvpn

ip link set bond0 down
ip link del bond0
killall openvpn

# recreate the bonding interface

ip link add bond0 type bond

ip addr add 10.8.0.254/24 dev bond0

for i in `seq 1 4`;
do
    openvpn --mktun --dev tap${i}
    ip link set tap${i} master bond0
done

for i in `seq 1 4`;
do
    systemctl start openvpn-server@server${i}.service
done

ip link set bond0 up mtu 1440
