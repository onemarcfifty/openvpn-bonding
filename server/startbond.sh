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

# define the bonding mode
ip link set bond0 down
sleep 2
echo $bondingMode > /sys/class/net/${bondInterface}/bonding/mode

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
#    systemctl start openvpn-server@server${i}.service
    openvpn --config /etc/openvpn/server/server${i}.conf --daemon
done

# last but not least bring up the bonded interface

ip link set $bondInterface up mtu 1440

# now find the WAN interface

# The initial idea here was to find the interface that has the public IP
# address. This will not work in a NAT environment, i.e.
# where the VPS is behind a NAT router and does not have the
# public address directly.

export OUR_OWN_IP=`sudo -u nobody curl -s ipinfo.io/ip`
readarray -d " " -t templine <<< $(ip -br addr | grep $OUR_OWN_IP)
export OUR_WAN_INTERFACE=${templine[0]}

# Fix : If we do not get an interface this way we just use the first 
# interface with the default route - we check for a minimum length of 3
# checking for zero length like this 
# [ -z "$OUR_WAN_INTERFACE" ] && export OUR_WAN_INTERFACE = ip route | grep default | sed s/.*dev\ //g | sed s/\ .*//g
# does not work because there is a line feed
# in the variable

if [ ${#OUR_WAN_INTERFACE} -le 2 ]; then
    echo "WAN Interface not found - was:${OUR_WAN_INTERFACE}:"
    export OUR_WAN_INTERFACE=`ip route | grep default | sed s/.*dev\ //g | sed s/\ .*//g`
    echo "WAN Interface is now: $OUR_WAN_INTERFACE"
fi

# now add the masquerading rules

iptables -A FORWARD -i bond0 -j ACCEPT
iptables -A FORWARD -o bond0 -j ACCEPT
iptables -t nat -A POSTROUTING -o $OUR_WAN_INTERFACE -j MASQUERADE

# now bring the bond interface up

ip link set bond0 up

# assign it the bondIP

ip addr add ${bondIP}/24 dev $bondInterface
