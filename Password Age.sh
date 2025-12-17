#!/bin/zsh

declare retval=""
declare userAccounts=($(dscl . list /Users | grep -v '^_' | grep -v 'daemon' | grep -v 'nobody' | grep -v 'root'| grep -v 'localmgr' ))
declare EntraCount=${#userAccounts[@]}

# Directory location of where the password info is kept
declare SUPPORT_DIR="Library/Application Support"
declare ENTRA_FILE="com.GiantEagleEntra.plist"

function run_for_each_user ()
{
    user_dir="/Users/$1/$SUPPORT_DIR/$ENTRA_FILE"

    # Extract the PasswordLastChanged field
    password_age=$(/usr/libexec/PlistBuddy -c "Print :PasswordAge" "$user_dir" 2>/dev/null)
    
    [[ $? -ne 0 ]] && return 1     # Check if the field was found
    if [[ "${#userAccounts[@]}" -eq 1 ]]; then #only one user on the system
        retval+=$password_age
    else
        if [[ "${LOGGED_IN_USER}" == "${1}" ]]; then
            retval+="$1: $password_age"
        fi
            #retval+="$1: $password_age"
    fi
}

# Main Script

for user in $userAccounts; do
  run_for_each_user $user
done
echo "<result>$retval</result>"
