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
mkdir -p /etc/openvpn/certs

# copy all necessary files into the openvpn config
# directory

cp commonConfig   /etc/openvpn
cp startbridge.sh /etc/openvpn
cp stopbridge.sh  /etc/openvpn

# now generate a CA and keys

touch /etc/openvpn/certs/serial
touch /etc/openvpn/certs/index.txt
echo "01" > /etc/openvpn/certs/serial

# generate a key pair for the Certification Authority
# you will be prompted for the password

openssl genrsa -aes256 -out /etc/openvpn/certs/vpn-cakey.pem 2048
chmod 0600 /etc/openvpn/certs/vpn-cakey.pem 

# now create CA certificate

openssl req -new -x509 -days 3650 -key /etc/openvpn/certs/vpn-cakey.pem -out /etc/openvpn/certs/vpn-ca.pem -set_serial 1

# generate a key for the server

openssl req -new -newkey rsa:1024 -out /etc/openvpn/certs/servercsr.pem -nodes -keyout /etc/openvpn/certs/serverkey.pem -days 3650
chmod 0600 /etc/openvpn/certs/serverkey.pem 

# generate and sign a certificate for the server

openssl x509 -req -in /etc/openvpn/certs/servercsr.pem -out /etc/openvpn/certs/servercert.pem -CA /etc/openvpn/certs/vpn-ca.pem -CAkey /etc/openvpn/certs/vpn-cakey.pem -CAserial  /etc/openvpn/certs/serial -days 3650

# create Diffie-Hellmann Parameter

openssl dhparam -out /etc/openvpn/certs/dh1024.pem 1024

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



