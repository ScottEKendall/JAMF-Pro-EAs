#!/bin/zsh
#
CiscoVPNApp="/opt/cisco/anyconnect/bin/vpn"
ip_address="Not Connected"
if [[ "$( echo 'state' |  $CiscoVPNApp -s | grep -m 1 ">> state:" )" == *'Connected' ]]; then
    ip_address=$($CiscoVPNApp -s stats | grep 'Client Address (IPv4)' | awk -F ': ' '{ print $2 }' | xargs)
fi
echo "<result>$ip_address</result>"
