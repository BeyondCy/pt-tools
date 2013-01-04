#!/bin/bash

# DNS backward resolutions of hosts

if [ -z "$4" ]; then
    echo "[*] Simple backward resolution of hosts in a range"
    echo "[*] Usage : $0 <class C ip>  <low> <high> <dns server>"
    echo "[*] Example : $0 213.177.4 160 175 213.177.4.161"
    exit 0
fi

# DNS server to use for resolution
server=$4

for ip in `seq $2 $3`;do
    #host $1.$ip $server | grep "name pointer" 
    dig @$server $ip.11.168.192.in-addr.arpa ptr +noquestion | grep PTR
done
