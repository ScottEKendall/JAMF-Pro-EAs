#!/bin/zsh
#Written by Ben Whitis - 08/11/2022
#Updated by Scott Kendall - 12/17/2025 for multi user macs

#Updated 11/29/2023 - use dscl to identify user home directory for scenarios where loggedInUser is an alias
#Updated 10/10/2024 - added support for platformSSO referencing @robjschroeder's EA
#Updated 10/03/2025 - modified how login keychain is queried, return device ID in result
#Updated 10/03/2025 - added support for 'getPSSOStatus' verb - REQUIRES JAMF PRO 11.21.1 OR HIGHER
#Updated 11/24/2025 - switch to 'launchctl asuser' instead of `su -c`
#updated 12/17/2025 - added routine for multiuser macs

run_for_each_user() {
  local loggedInUser="$1"
  local userHome
  local platformStatus
  local plist
  local jamfCA="/Library/Application Support/JAMF/Jamf.app/Contents/MacOS/Jamf Conditional Access.app/Contents/MacOS/JAMF Conditional Access"

  #get user home directory
  userHome=$(/usr/bin/dscl . read "/Users/$loggedInUser" NFSHomeDirectory | /usr/bin/awk -F ' ' '{print $2}')

  #Check if registered via PSSO/SSOe first
  ssoStatus=$(/bin/launchctl asuser $( /usr/bin/id -u $loggedInUser ) /Library/Application\ Support/JAMF/Jamf.app/Contents/MacOS/Jamf\ Conditional\ Access.app/Contents/MacOS/Jamf\ Conditional\ Access getPSSOStatus | tr -d '()[]"' | sed -E 's/, /\n/g')
  if [[ $ssoStatus == *"primary_registration_metadata_device_id"* ]]; then
    #Check if jamfAAD registered too
    AAD_ID=$(/usr/bin/defaults read  "$userHome/Library/Preferences/com.jamf.management.jamfAAD.plist" have_an_Azure_id)
    if [[ $AAD_ID -eq "1" ]]; then
      ssoStatus=$(echo $ssoStatus  | sed -E 's/(extraDeviceInformation |AnyHashable|primary_registration_metadata_)//g')
      #jamfAAD ID exists, and PSSO/SSOe registered. Return getPSSOStatus results
      retval+="Registered - $userHome\nDetails:\n$ssoStatus"
      return 0
    fi
    #SSOe/PSSO secure enclave registered but not jamfAAD registered
    retval+="WPJ Key is in Secure Enclave, but AAD ID not acquired for user home: $userHome"
  fi

  #Fall back to legacy (Login Keychain) checks
  #check if wpj private key is present
  WPJKey=$(/bin/launchctl asuser $( /usr/bin/id -u $loggedInUser ) "/usr/bin/security find-certificate -a -Z | /usr/bin/grep -B 9 "MS-ORGANIZATION-ACCESS" | /usr/bin/awk '/\"alis\"<blob>=\"/ {print $NF}' | /usr/bin/sed 's/\"alis\"<blob>=\"//;s/.$//'")
  if [ ! -z "$WPJKey" ]
  then
    #WPJ key is present
    #check if jamfAAD plist exists
    plist="$userHome/Library/Preferences/com.jamf.management.jamfAAD.plist"
    if [ ! -f "$plist" ]; then
      #plist doesn't exist
        retval+="WPJ Key present, JamfAAD PLIST missing from user home: $userHome\nDevice ID: $WPJKey"
        return 0
    fi

    #PLIST exists. Check if jamfAAD has acquired AAD ID
    AAD_ID=$(/usr/bin/defaults read  "$userHome/Library/Preferences/com.jamf.management.jamfAAD.plist" have_an_Azure_id)
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
declare userAccounts=($(dscl . list /Users | grep -v '^_' | grep -v 'daemon' | grep -v 'nobody' | grep -v 'root'| grep -v 'localmgr' ))

for user in $userAccounts; do
  run_for_each_user $user
  retval+="\n"
done
echo "<result>$retval</result>"