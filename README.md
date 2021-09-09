# openvpn-bonding

The scripts in this repository may be used to bond multiple VPN interfaces together and hence increase (i.e. double, triple, quadruple....) your internet speed.

The way this is achieved is by installing openvpn as a server on a VPS (i.e. a virtual Server which you can rent from any VPS provider) and running a vpn client on your home network environment (i.e. a raspberry pi, in a VM or on an OpenWRT router)

The network interfaces which are specified in the configuration file are then bonded on the client and on the server side and effectively aggregate the available internet speed over multiple connections.

Find all details on [my youtube channel](https://www.youtube.com/channel/UCG5Ph9Mm6UEQLJJ-kGIC2AQ)

The work is greatly inspired by [this article on serverfault by legolas108](https://serverfault.com/questions/977589/how-to-bond-two-multiple-internet-connections-for-increased-speed-and-failover)

IMPORTANT: Please note that this works only for IP V4 at the moment
IP V6 is future work

*** PPP Interfaces replace line 76 of client side startbond.sh with:
    readarray -td " " templine <<< $(ip -br route | grep ${!tunnelInterface} | grep src)

If you are having issues with these scripts (they don't work as expected etc.) then you may join my discord server and chat life with me - please see [THIS VIDEO](https://youtu.be/VouCBt1NTjw) for details
