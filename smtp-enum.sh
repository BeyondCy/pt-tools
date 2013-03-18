#!/bin/bash

if [ -z "$1" ]; then
    echo "[*] Simple SMTP user enumeration. Uses VRFY, EXPN and RCPT TO methods"
    echo "[*] Usage : $0 <servers_file>"
    echo "[*] Example : $0 servers.txt"
    exit 0
fi

addr="test@example.com"
user="test_user"
servers=$1
for ip in `cat $servers`; do
	echo "[*] Checking host: " $ip
	echo "Sending VRFY..."
	echo -e "HELO jj\r\nVRFY $user\r\n" | nc -v -n $ip 25
	echo "Sending EXPN..."
	echo -e "HELO jj\r\nEXPN $user\r\n" | nc -v -n $ip 25
	echo "Sending RCPT..."
	echo -e "HELO jj\r\nMAIL FROM: $addr\r\nRCPT TO:$user\r\n" | nc -v -n $ip 25
	echo "----------------------------"
done

