@echo off

rem Get current username
for /f "delims=" %%a in ('whoami') do @set username=%%a
echo Current username: %username%

rem Change IP and DNS
netsh interface ip set address name="Local Area Connection" source=static addr=192.168.0.200 mask=255.255.255.0 gateway=192.168.0.1
runas /user:%username% "netsh interface ip set  dnsservers name=\"Local Area Connection\" source=static address=192.168.0.100"
runas /user:%username% "netsh interface ip add  dnsservers name=\"Local Area Connection\" address=192.168.0.1 index=2"

rem Check
echo "IP settings:"
netsh interface ip  show dnsservers "Local Area Connection"
echo "DNS settings:"
netsh interface ip  show addresses "Local Area Connection"

pause
