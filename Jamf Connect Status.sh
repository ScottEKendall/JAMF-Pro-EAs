#!/bin/zsh

RESULT="Not Installed"

if [[ -f "/usr/local/bin/authchanger" ]]; then
    JAMF_CONNECT_STATUS=$(/usr/local/bin/authchanger -print | grep JamfConnectLogin)
	[[ $? == 0 ]] && RESULT="Enabled" || RESULT="Disabled"
fi
echo "<result>$RESULT</result>"
