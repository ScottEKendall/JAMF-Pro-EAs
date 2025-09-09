#!/bin/zsh
run_for_each_user()
{
    SUPPORT_DIR="/Users/$1/Library/Application Support"
    JSS_FILE="$SUPPORT_DIR/com.GiantEagleEntra.plist"

    admin_rights=$(/usr/libexec/PlistBuddy -c "Print EntraAdminRights" "$JSS_FILE" 2>&1)
    [[ "$admin_rights" == *"Does Not Exist"* ]] && admin_rights="Unknown"
    if [[ "$userCount" -eq 1 ]]; then #only one user on the system
        retval+=$admin_rights
    else
        retval+="$1 - $admin_rights\n"
    fi
}

# Main Script

declare retval=""
declare userAccounts=($(dscl . list /Users | grep -v '^_' | grep -v 'daemon' | grep -v 'nobody' | grep -v 'root' | grep -v 'localmgr' ))
declare userCount=${#userAccounts[@]}

for user in $userAccounts; do
  run_for_each_user $user
done
echo "<result>$retval</result>"