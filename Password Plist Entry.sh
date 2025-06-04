#!/bin/zsh

JSS_FILE="/Library/Managed Preferences/com.gianteagle.jss.plist"

passwordExpireDate=$(/usr/libexec/plistbuddy -c "print PasswordLastChanged" $JSS_FILE 2>&1)
echo "<result>$passwordExpireDate</result>"
