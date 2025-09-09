#!/bin/zsh

declare retval=""
declare userAccounts=($(dscl . list /Users | grep -v '^_' | grep -v 'daemon' | grep -v 'nobody' | grep -v 'root'| grep -v 'localmgr' ))
declare EntraCount=${#userAccounts[@]}

declare SUPPORT_DIR="Library/Application Support"
declare JSS_FILE="com.GiantEagleEntra.plist"

function run_for_each_user ()
{
    user_dir="/Users/$1/$SUPPORT_DIR/$JSS_FILE"

    # Extract the PasswordLastChanged field
    password_last_changed=$(/usr/libexec/PlistBuddy -c "Print :PasswordLastChanged" "$user_dir" 2>/dev/null)
    
    [[ $? -ne 0 ]] && exit 1     # Check if the field was found
    if [[ "$EntraCount" -eq 1 ]]; then #only one user on the system
        retval+=$password_last_changed
    else 
        retval+="$1: $password_last_changed\n"
    fi
}

# Main Script

for user in $userAccounts; do
  run_for_each_user $user
done
echo "<result>$retval</result>"
