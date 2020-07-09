#!/bin/bash

# #############################################
#
# install.sh - run as root.
#
# installs openvpn, openssl and bridge-utils
#
# creates a Certification Authority (CA)
# and all necessary keys and certs for one server
# and 4 clients
#
# creates 4 server configs with tap bridging
#
# #############################################

# the script needs to be called from the directory where
# the commonConfig file and the start/stop bridge files 
# are located

. commonConfig

apt -y install openvpn openssl bridge-utils sed
# mkdir -p /etc/openvpn/certs

# we will use the sample keys from the openvpn package
ln -s /usr/share/doc/openvpn/examples/sample-keys /etc/openvpn/certs

# copy all necessary files into the openvpn config
# directory

cp commonConfig   /etc/openvpn
cp startbridge.sh /etc/openvpn
cp stopbridge.sh  /etc/openvpn


# now create a config file for each server instance 

for counter in `seq 1 $numberOfTunnels`;
do
    # the config files will be called server1.conf, server2.conf aso

    vpnConfigFile=/etc/openvpn/server/server${counter}.conf
    cp config/server.conf.template $vpnConfigFile

    # now we just replace the placeholders in the template file
    # @tap is replaced with tap0, tap1 etc.

    sed -i s/@dev/tap${counter}/g          $vpnConfigFile

    # we dont need ip addresses for the tap interfaces as they are bridged

#    sed -i s/@ip/"${ipTrunk}.${counter}"/g $vpnConfigFile
#    sed -i s/@mask/$ipMask/g $vpnConfigFile

    # we replace the @port placeholder with ports 1191, 1192, 1193 and so on

    sed -i s/@port/119${counter}/g $vpnConfigFile

    # enable the corresponding system unit

    systemctl enable openvpn-server@server${counter}.service
done


# use the provided example keys
# the sample script calls openvpn from a non-existent directory if you do not have
# the source packages, so we just symlink to the openvpn binary
# this is _really_ quick and dirty - but it works ;-)

cd /usr/share/doc/openvpn/examples/sample-keys
mkdir -p ../../src/openvpn/
ln -s /usr/sbin/openvpn ../../src/openvpn/openvpn
./gen-sample-keys.sh

cd /etc/openvpn

