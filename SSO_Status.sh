#!/bin/zsh
result=""
appleSSO=$(app-sso platform -s | grep "registrationCompleted" | awk -F ":" '{print $2}' | xargs | tr -d ",")
jamfSSO=$("/Library/Application Support/JAMF/Jamf.app/Contents/MacOS/Jamf Conditional Access.app/Contents/MacOS/Jamf Conditional Access" getPSSOStatus | head -n 1)

# Various test cases
if [[ $appleSSO == "false" ]]; then
    result="APPLE: Not Registered\n"
else
    result="APPLE: Registered Properly\n"
fi
if [[ $jamfSSO == "0" ]]; then
    result+="JAMF: Not Enabled (0)"
elif [[ $jamfSSO == "1" ]]; then
    result+="JAMF: Not Registerd (1)"
else
    result+="JAMF: Registered Properly (2)"
fi
echo "<result>"$result"</results>"
