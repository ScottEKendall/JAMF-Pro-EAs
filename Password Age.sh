#!/bin/zsh
#
# by: Scott Kendall
#
# Written: 04/17/2025
# Last updated: 04/17/2025

# Script to populate /Library/Managed Preferences/com.gianteagle.jss file with uses EntraID password info
# 
# 1.0 - Initial code
#

JSS_FILE="/Library/Managed Preferences/com.gianteagle.jss.plist"

function duration_in_days ()
{
    # PURPOSE: Calculate the difference between two dates
    # RETURN: days elapsed
    # EXPECTED: 
    # PARMS: $1 - oldest date 
    #        $2 - newest date
    local start end
    calendar_scandate $1        
    start=$REPLY        
    calendar_scandate $2        
    end=$REPLY        
    echo $(( ( end - start ) / ( 24 * 60 * 60 ) ))
}
####################################################################################################
#
# Main Script
#
####################################################################################################
autoload 'calendar_scandate'
passwordExpireDate=$(/usr/libexec/plistbuddy -c "print PasswordLastChanged" $JSS_FILE 2>&1)
curUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

if [[ $passwordExpireDate == *"Does Not Exist"* || -z $passwordExpireDate ]]; then
    # Not populated yet, so fall back to the local login password change
    passwordAge=$(expr $(expr $(date +%s) - $(dscl . read /Users/${curUser} | grep -A1 passwordLastSetTime | grep real | awk -F'real>|</real' '{print $2}' | awk -F'.' '{print $1}')) / 86400)
else
    #found the key, so determine the days based off of that
    passwordAge=$(duration_in_days $passwordExpireDate $(date))
fi
echo "<result>$passwordAge</result>"
