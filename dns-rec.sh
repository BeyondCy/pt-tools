#!/bin/bash

# DNS reconnissance: find servers in range

if [ -z "$3" ]; then
    echo "[*] Find name servers from hosts in a range"
    echo "[*] Usage : $0 <class C ip>  <low> <high>"
    echo "[*] Example : $0 192.168.11 200 254"
    exit 0
fi

base_ip=$1
low=$2
high=$3
port=53

for ip in `seq $low $high`;do
    # nc outputs to stderr, so we redirect it before grep-ing
    nc -vv -n -z -w 1 $base_ip.$ip $port 2>&1 | grep -i open
done
