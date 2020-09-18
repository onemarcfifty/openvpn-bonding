#!/bin/ash

# #############################################
#
# install.sh - run as root.
#
# installs openvpn, openssl and bridge-utils
#
# you need to have a client key ready
# in /etc/openvpn/ta.key
#
# creates n client configs with tap bridging
#
# #############################################

# the script needs to be called from the directory where
# the commonConfig file and the start/stop bridge files 
# are located

. ./commonConfig

#apt update && apt -y install openvpn openssl bridge-utils sed
opkg update && opkg install openvpn-openssl luci-app-openvpn kmod-bonding

# copy all necessary files into the openvpn config
# directory

cp ./commonConfig   /etc/openvpn
cp ./startbond.sh /etc/openvpn
cp ./stopbond.sh  /etc/openvpn

mkdir -p /etc/openvpn/client

for counter in `seq 1 $numberOfTunnels`;
do
    # the config files will be called server1.conf, server2.conf aso

    vpnConfigFile=/etc/openvpn/client/client${counter}.conf
    cp config/client.conf.template $vpnConfigFile

    # now we just replace the placeholders in the template file
    # @tap is replaced with tap0, tap1 etc.

    sed -i s/@dev/tap${counter}/g          $vpnConfigFile
    sed -i s/@server/${vpnServer}/g $vpnConfigFile

    # we dont need ip addresses for the tap interfaces as they are bridged

    sed -i s/@ip/"${ipTrunk}.${counter}"/g $vpnConfigFile
    sed -i s/@mask/$ipMask/g $vpnConfigFile

    # we replace the @port placeholder with ports 1191, 1192, 1193 and so on

    sed -i s/@port/119${counter}/g $vpnConfigFile

    # enable the corresponding system unit

    #systemctl enable openvpn-client@client${counter}.service
    # (had to change it as systemctl calls openvpn with nobind option
    # but we have to bind to specific interfaces)


    # now add a routing table for each interface
    # but keep it commented out until the bond is actually started
    # we will start enumerating the routing tables at 11,
    # i.e. add 10 to the number of the table
    # so this will result in #11 vpn1, #12 vpn2 and so on
    # needed to make this a bit more complicated because someone
    # might run the install multiple times

    # case 1 - the table already exists, then we comment it out
    if grep "^1${counter} vpn${counter}" /etc/iproute2/rt_tables  
    then
        sed -i s/"^1${counter} vpn${counter}"/"#1${counter} vpn${counter}"/g /etc/iproute2/rt_tables
    else    
        # case 2 - the table does not exist, then we add it
        if ! grep "1${counter}.*vpn${counter}" /etc/iproute2/rt_tables
        then
          echo "#1${counter} vpn${counter}" >>/etc/iproute2/rt_tables
        fi
    fi
done

echo "the routing table is as follows:"
cat /etc/iproute2/rt_tables


