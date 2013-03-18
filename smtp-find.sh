#!/bin/bash

if [ -z "$1" ]; then
    echo "[*] Simple SMTP discovery script"
    echo "[*] Usage : $0 <hosts_file>"
    echo "[*] Example : $0 hosts.txt"
    exit 0
fi

hosts=$1
for ip in `cat $hosts`;do
	nmap -sS -P0 -p 25 -oG - $ip | grep open &
done
