#!/bin/zsh
# Check to see if the zScaler tunnel is running

tunnel=$( pgrep -i ZscalerTunnel )
#processcount=$(pgrep -i zscalerTunnel | wc| awk '{print $1}')
#daemoncount=$(launchctl list | grep zscaler | wc | awk '{print $2}')

currentUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
keychainKey=$(su - $currentUser -c "security find-generic-password -l 'com.zscaler.tray'")

# If the keychain entry is not found, they haven't logged in
[[ ! -z $keychainKey ]] && zStatus="Logged In" || zStatus="Not Logged In"
[[ -z $tunnel ]] && zStatus="Tunnel Bypassed"

# if the http test doesn't resolve to zscaler, then the tunnel has been bypassed
orgsite=$(curl -f https://ipinfo.io/json | grep org | awk -F ":" '{print $2}' | tr -d ",")
[[ $orgsite == *"ZSCALER"* && ! -z $keychainKey ]] && RESULT="Protected" || RESULT="No Active Tunnel"
 
#report results
echo "<result>$zStatus | $orgsite</result>"
