#!/bin/zsh
#
# Determine if local user is logged into an iCloud account
# If so, then display the logged in account name
LOGGED_IN_USER=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
USER_DIR=$( dscl . -read /Users/${LOGGED_IN_USER} NFSHomeDirectory | awk '{ print $2 }' )

iCloudLoggedInCheck=$(defaults read $USER_DIR/Library/Preferences/MobileMeAccounts Accounts)

if [[ "$iCloudLoggedInCheck" = *"AccountID"* ]]; then
	iCloudLoggedIn="Yes"
    iCloudUser=$(echo $iCloudLoggedInCheck | grep "AccountID" | awk -F " " '{print $NF}' | tr -d '"' | tr -d ";")
    iCloudLoggedIn+=" | "$iCloudUser
else
	iCloudLoggedIn="No"
fi
echo "<result>$iCloudLoggedIn</result>"
