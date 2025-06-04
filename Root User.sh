#!/bin/bash
# Source: https://community.jamf.com/t5/jamf-pro/how-to-disable-root-for-users-that-have-enabled-root-on-their/m-p/242644
rootCheck=`dscl . read /Users/root | grep AuthenticationAuthority 2>&1 > /dev/null ; echo $?`
if [ "${rootCheck}" == 1 ]; then
	echo "<result>Disabled</result>"
else
	echo "<result>Enabled</result>"
fi
