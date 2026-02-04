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

additionalAccountsToExclude='|appleadmin|macadmin' #use ' quotes; empty or comment out if not used; leave leading | if used; only separate by | as this will be inserted into a regex

get_device_compliance_registration_status() {
  local loggedInUser="$1"
  local userHome
  local platformStatus
  local plist
  local jamfCA="/Library/Application Support/JAMF/Jamf.app/Contents/MacOS/Jamf Conditional Access.app/Contents/MacOS/JAMF Conditional Access"

  #get user home directory
  local userHome=$(/usr/bin/dscl . read "/Users/$loggedInUser" NFSHomeDirectory | /usr/bin/awk -F ' ' '{print $2}')

  #Check if registered via PSSO/SSOe first
  local ssoStatus=$(/bin/launchctl asuser $( /usr/bin/id -u $loggedInUser ) /Library/Application\ Support/JAMF/Jamf.app/Contents/MacOS/Jamf\ Conditional\ Access.app/Contents/MacOS/Jamf\ Conditional\ Access getPSSOStatus | tr -d '()[]"' | sed -E 's/, /\n/g')
  if [[ $ssoStatus == *"primary_registration_metadata_device_id"* ]]; then
    #Check if jamfAAD registered too
    AAD_ID=$(/usr/bin/defaults read  "$userHome/Library/Preferences/com.jamf.management.jamfAAD.plist" have_an_Azure_id)
    if [[ $AAD_ID -eq "1" ]]; then
      local ssoStatus=$(echo $ssoStatus  | sed -E 's/(extraDeviceInformation |AnyHashable|primary_registration_metadata_)//g')
      #jamfAAD ID exists, and PSSO/SSOe registered. Return getPSSOStatus results
      retval+="Registered - $userHome\nDetails:\n$ssoStatus"
      return 0
    fi
    #SSOe/PSSO secure enclave registered but not jamfAAD registered
    retval+="WPJ Key is in Secure Enclave, but AAD ID not acquired for user home: $userHome"
  fi

  #Fall back to legacy (Login Keychain) checks
  #check if wpj private key is present
  local WPJKey=$(/bin/launchctl asuser $( /usr/bin/id -u $loggedInUser ) "/usr/bin/security find-certificate -a -Z | /usr/bin/grep -B 9 "MS-ORGANIZATION-ACCESS" | /usr/bin/awk '/\"alis\"<blob>=\"/ {print $NF}' | /usr/bin/sed 's/\"alis\"<blob>=\"//;s/.$//'")
  if [ ! -z "$WPJKey" ]
  then
    #WPJ key is present
    #check if jamfAAD plist exists
    local plist="$userHome/Library/Preferences/com.jamf.management.jamfAAD.plist"
    if [ ! -f "$plist" ]; then
      #plist doesn't exist
        retval+="WPJ Key present, JamfAAD PLIST missing from user home: $userHome\nDevice ID: $WPJKey"
        return 0
    fi

    #PLIST exists. Check if jamfAAD has acquired AAD ID
    local AAD_ID=$(/usr/bin/defaults read  "$userHome/Library/Preferences/com.jamf.management.jamfAAD.plist" have_an_Azure_id)
    if [[ $AAD_ID -eq "1" ]]; then
      #jamfAAD ID exists
      retval+="Registered - $userHome\nDevice ID: $WPJKey"
      return 0
    fi

    #WPJ is present but no AAD ID acquired:
    retval+="WPJ Key Present. AAD ID not acquired for user home: $userHome\nDevice ID: $WPJKey"
    return 0
  fi

  #no wpj key
  echo "Not Registered for user home $userHome"
}

# Main Script
declare retval=""
declare userAccounts=($(dscl . list /Users | grep -vE "^(_|daemon|nobody|root|localmgr${additionalAccountsToExclude})"))

for user in $userAccounts; do
  get_device_compliance_registration_status $user
  retval+="\n"
done

if [[ -n $retval ]]; then
  echo "<result>$retval</result>"
fi
