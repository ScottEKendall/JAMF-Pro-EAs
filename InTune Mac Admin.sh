#!/bin/zsh

LOGGED_IN_USER=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

SUPPORT_DIR="/Users/$LOGGED_IN_USER/Library/Application Support"
JSS_FILE="$SUPPORT_DIR/com.GiantEagleEntra.plist"

admin_rights=$(/usr/libexec/PlistBuddy -c "Print EntraAdminRights" "$JSS_FILE" 2>&1)
[[ "$admin_rights" == *"Does Not Exist"* ]] && admin_rights="Unknown"

echo "<result>$admin_rights</result>"