#!/bin/bash

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

. commonConfig

apt update && apt -y install openvpn openssl bridge-utils sed

# copy all necessary files into the openvpn config
# directory

cp commonConfig   /etc/openvpn
cp startbond.sh /etc/openvpn
cp stopbond.sh  /etc/openvpn

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

    systemctl enable openvpn-client@client${counter}.service
done



