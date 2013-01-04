#!/bin/bash

# Identify hardware type and operating system versions of SNMP enabled machines
# e.g. :
# # ./snmp-find.sh  213.177.4 160 162
#    160 :
#    SNMPv2-MIB::sysDescr.0 = STRING: Hardware: x86 Family 6 Model 7 Stepping 10 AT/AT COMPATIBLE - 
#                           Software: Windows 2000 Version 5.1 (Build 2600 Uniprocessor Free)
#    161 :
#    SNMPv2-MIB::sysDescr.0 = STRING: Hardware: x86 Family 6 Model 7 Stepping 10 AT/AT COMPATIBLE - 
#                           Software: Windows 2000 Version 5.1 (Build 2600 Uniprocessor Free)
#    162 :
#    Timeout: No Response from 213.177.4.163


if [ -z "$3" ]; then
    echo "[*] Simple SNMP info gather of hosts in a range"
    echo "[*] Usage : $0 <class C ip>  <low> <high>"
    echo "[*] Example : $0 213.177.4 160 175"
    exit 0
fi

for ip in `seq $2 $3`;do
    echo $ip ":"
    snmpwalk -c public -v1 $1.$ip SNMPv2-MIB::sysDescr.0
done
