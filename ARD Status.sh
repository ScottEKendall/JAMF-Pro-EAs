#!/bin/zsh

AdminUserName="localmgr"
result=""
RemoteDesktopStatus=$(sudo launchctl list | grep -i 'ScreenSharing' | awk '{print $3}' | xargs)
RemoteDesktopStatus=$(echo $RemoteDesktopStatus)
LAPermissionsGranted=$(dscl . -list /Users dsAttrTypeNative:naprivs | grep "${AdminUserName}" | awk '{print $1}' | xargs)


# Determines if the Remote Management settings are set
# for "All Users" or for "Only these users:" in System
# Preferences' Sharing preference pane

ARD_ALL_LOCAL=$(/usr/bin/defaults read /Library/Preferences/com.apple.RemoteManagement ARD_AllLocalUsers)

# Lists all local user accounts on the Mac with a UID 
# of greater or equal to 500 and less than 1024. This 
# should exclude all system accounts and network accounts
# 
# List is displayed if the "All Users" setting is 
# set in the Remote Management settings.

ALL_ID500_PLUS_LOCAL_USERS=$(/usr/bin/dscl . list /Users UniqueID | awk '$2 >= 500 && $2 < 1024 { print $1; }')

# Lists all user accounts on the Mac that have been given
# explicit Remote Management rights. List is displayed if 
# the "Only these users:" setting is set in the Remote 
# Management settings.

REMOTE_MANAGEMENT_ENABLED_USERS=$(/usr/bin/dscl . list /Users naprivs | awk '{print $1}')

[[ "$ARD_ALL_LOCAL" = "1" ]] && ARDusers=$ALL_ID500_PLUS_LOCAL_USERS || ARDUsers=$REMOTE_MANAGEMENT_ENABLED_USERS

echo $ARDUsers
#If Monterey or 'next' or earlier, report status.

if [[ $RemoteDesktopStatus == "" ]] && [[ $LAPermissionsGranted == "" ]]; then
  results="Off. None."
elif [[ $RemoteDesktopStatus == "com.apple.screensharing" ]] && [[ $LAPermissionsGranted == "" ]]; then
  result="On. None."
elif [[ $RemoteDesktopStatus == "com.apple.screensharing.agent com.apple.screensharing com.apple.screensharing.menuextra" ]] && [[ $LAPermissionsGranted == "" ]]; then
  result="On. None."
elif [[ $RemoteDesktopStatus == "com.apple.screensharing" ]] && [[ $LAPermissionsGranted == "${AdminUserName}" ]]; then
  result="On | ${ARDUsers}"
elif [[ $RemoteDesktopStatus == "com.apple.screensharing.agent com.apple.screensharing com.apple.screensharing.menuextra" ]] && [[ $LAPermissionsGranted == "${AdminUserName}" ]]; then
  result="On | ${ARDUsers}"
elif [[ $RemoteDesktopStatus == "" ]] && [[ $LAPermissionsGranted == "${AdminUserName}" ]]; then
  result="Off. Set."
else
  result="Unknown config."
fi

echo "<result>${result}</result>"
