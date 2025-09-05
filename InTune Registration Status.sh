#!/bin/zsh
#Written by Ben Whitis - 08/11/2022
#Updated by Scott Kendall - 07/18/2025

#Updated 11/29/2023 - use dscl to identify user home directory for scenarios where loggedInUser is an alias
#Updated 10/10/2024 - added support for platformSSO referencing @robjschroeder's EA
#updated 07/18/2025 - added routine for multiuser macs

run_for_each_user() {
    local user="$1"
    local userHome
    local platformStatus
    local plist

    # More efficient user home directory retrieval in zsh
    userHome=$(dscl . -read "/Users/$user" NFSHomeDirectory | cut -d' ' -f2)

    # Platform SSO registration check with zsh-optimized parsing
    platformStatus=$(su "$user" -c "app-sso platform -s" 2>/dev/null | awk '/registration/ {gsub(/,/, ""); print $3}')

    # Zsh-specific parameter expansion and conditional checks
    if [[ "$platformStatus" == "true" ]]; then
        # Simplified check for jamfAAD registration
        if [[ -f "$userHome/Library/Preferences/com.jamf.management.jamfAAD.plist" ]] && 
           defaults read "$userHome/Library/Preferences/com.jamf.management.jamfAAD.plist" have_an_Azure_id &>/dev/null; then
            retval+="Registered with Platform SSO - $userHome"
            return 0
        fi
        retval+="Platform SSO registered but AAD ID not acquired for user home: $userHome"
        return 0
    fi

    # WPJ key check with zsh parameter expansion
    if security dump "$userHome/Library/Keychains/login.keychain-db" | grep -q MS-ORGANIZATION-ACCESS; then
        plist="$userHome/Library/Preferences/com.jamf.management.jamfAAD.plist"
        
        # Zsh file test and plist check
        if [[ ! -f "$plist" ]]; then
            retval+="WPJ Key present, JamfAAD PLIST missing from user home: $userHome"
            return 0
        fi

        # Check AAD ID acquisition
        if defaults read "$plist" have_an_Azure_id &>/dev/null; then
            retval+="Registered - $userHome"
            return 0
        fi

        retval+="WPJ Key Present. AAD ID not acquired for user home: $userHome"
        return 0
    fi

    # No registration found
    retval+="Not Registered for user home $userHome"
}
# Main Script
declare retval=""
declare userAccounts=($(dscl . list /Users | grep -v '^_' | grep -v 'daemon' | grep -v 'nobody' | grep -v 'root'| grep -v 'localmgr' ))

for user in $userAccounts; do
  run_for_each_user $user
  retval+="
"
done
echo "<result>$retval</result>"
