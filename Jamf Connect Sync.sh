#!/bin/zsh

RESULT="Not Installed"
currentUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
jamfstate=$(su - $currentUser -c "defaults read com.jamf.connect.state")
PasswordStatus=$(echo $jamfstate | grep PasswordCurrent | awk -F "=" '{print $2}' | tr -d ";" | xargs)
[[ ${PasswordStatus} == 1 ]] && RESULT="In Sync" || RESULT="Not Synced"
echo "<result>$RESULT</result>"
