#!/bin/zsh
#Written by Ben Whitis - 08/11/2022
#Updated by Scott Kendall - 12/17/2025 for multi user macs

#Updated 11/29/2023 - use dscl to identify user home directory for scenarios where loggedInUser is an alias
#Updated 10/10/2024 - added support for platformSSO referencing @robjschroeder's EA
#Updated 10/03/2025 - modified how login keychain is queried, return device ID in result
#Updated 10/03/2025 - added support for 'getPSSOStatus' verb - REQUIRES JAMF PRO 11.21.1 OR HIGHER
#Updated 11/24/2025 - switch to 'launchctl asuser' instead of `su -c`
#updated 12/17/2025 - added routine for multiuser macs
#updated 01/15/2026 - added variable to exclude local accounts & simplified dscl command with regex capture group (@hkystar35)
#                   - added if block to Jamf result in order to preserve last server inventory data (@hkystar35)
#                   - variable updates to keep consitent with function (@hkystar35)
#                   - update function name to reflect function work; the function is not looping through each user (@hkystar35)
# updated 02/04/2026 - Reworked pSSO status to show more concise information 

additionalAccountsToExclude='|appleadmin|macadmin' #use ' quotes; empty or comment out if not used; leave leading | if used; only separate by | as this will be inserted into a regex

function runAsUser ()
{
   /bin/launchctl asuser $userUID sudo -iu $loggedInUser "$@"
}

function get_device_compliance_registration_status() {
    local loggedInUser="$1"
    local userUID=$(/usr/bin/id -u $loggedInUser)
    local userHome=$(/usr/bin/dscl . read "/Users/$loggedInUser" NFSHomeDirectory | /usr/bin/awk -F ' ' '{print $2}')
    local jamfCA="/Library/Application Support/JAMF/Jamf.app/Contents/MacOS/Jamf Conditional Access.app/Contents/MacOS/JAMF Conditional Access"

    # Check if registered via PSSO/SSOe first
    local ssoStatus=$(runAsUser $jamfCA getPSSOStatus | tr -d '()[]"' | sed -E 's/, /\n/g')

    if [[ $ssoStatus == *"primary_registration_metadata_device_id"* ]]; then
        # Check if jamfAAD registered too
        AAD_ID=$(/usr/bin/defaults read  "$userHome/Library/Preferences/com.jamf.management.jamfAAD.plist" have_an_Azure_id)
        if [[ $AAD_ID -eq "1" ]]; then
            AADstatus=$(echo $ssoStatus | /usr/bin/head -n1 | /usr/bin/tr -d '[:space:]')
            ssoStatus=$(echo $ssoStatus  | sed -E 's/(extraDeviceInformation |AnyHashable|primary_registration_metadata_)//g')

            # jamfAAD ID exists, and PSSO/SSOe registered. Return getPSSOStatus results and parse the info
            field_upn=$(printf '%s\n' "$ssoStatus" | /usr/bin/awk -F "upn: " 'NF>1{print $2}')
            upn=$(printf '%s\n' "$field_upn" | /usr/bin/grep -Eo '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'| /usr/bin/head -1)

            # the UPN from the jamfAAD Command could be blank, so lets grab this from the Apple SSO command and construct it
            if [[ -z $upn ]]; then
                local raw_upn=$(runAsUser app-sso platform -s | grep '"upn"'| sed -E 's/.*"upn"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')
                raw_upn=${raw_upn//\\@/@}           # unescape \@
                local email=${raw_upn/\\*}          # keep everything up to first '@'
                local domain_part=${raw_upn#*@}     # everything after first '@'
                upn="$email@${domain_part%@*}"      # append domain up to second '@'
            fi

            field_device=$(printf '%s\n' "$ssoStatus" | /usr/bin/awk -F "device_id: " 'NF>1{print $2; exit}')
            device_id=$(printf '%s\n' "$field_device" | /usr/bin/grep -Eo '[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}'| /usr/bin/head -1)

            case "${AADstatus}" in
                0 ) joinmethod="pSSO Not Enabled" ;;
                1 ) joinmethod="pSSO Enabled not registered" ;;
                2 ) joinmethod="pSSO Enabled and registered" ;;
            esac
            retval+="$joinmethod ($AADstatus) | ${upn:-NoUPNFound} | ${device_id:-NoDeviceIDFound} | $userHome"
            return 0
        fi
        # SSOe/PSSO secure enclave registered but not jamfAAD registered
        retval+="WPJ Key is in Secure Enclave, but AAD ID not acquired for user home: $userHome"
    fi

    # Fall back to legacy (Login Keychain) checks  / check if WPJ private key is present
    local WPJKey=$(runAsUser "/usr/bin/security find-certificate -a -Z | /usr/bin/grep -B 9 "MS-ORGANIZATION-ACCESS" | /usr/bin/awk '/\"alis\"<blob>=\"/ {print $NF}' | /usr/bin/sed 's/\"alis\"<blob>=\"//;s/.$//'")
    # See if no key is present
    [[ -z "$WPJKey" ]] && { etval+="Not Registered for user home $userHome"; return 0; }
    # WPJ key is present, so do some more checking
    # check if jamfAAD plist exists
    if [ ! -f "$userHome/Library/Preferences/com.jamf.management.jamfAAD.plist" ]; then
        # plist doesn't exist
        retval+="WPJ Key present, JamfAAD PLIST missing from user home: $userHome\nDevice ID: $WPJKey"
        return 0
    fi

    # PLIST exists. Check if jamfAAD has acquired AAD ID
    
    if [[ $AAD_ID -eq "1" ]]; then
        # jamfAAD ID exists
        retval+="Registered - $userHome\nDevice ID: $WPJKey"
        return 0
    fi

    #WPJ is present but no AAD ID acquired:
    retval+="WPJ Key Present. AAD ID not acquired for user home: $userHome\nDevice ID: $WPJKey"
    return 0
}

# Main Script
declare retval=""
declare userAccounts=($(dscl . list /Users | grep -vE "^(_|daemon|nobody|root|localmgr${additionalAccountsToExclude})"))

for user in $userAccounts; do
  get_device_compliance_registration_status $user
  retval+="\n"
done

[[ -n $retval ]] && echo "<result>$retval</result>"
