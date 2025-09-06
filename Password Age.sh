#!/bin/zsh

declare retval=""
declare userAccounts=($(dscl . list /Users | grep -v '^_' | grep -v 'daemon' | grep -v 'nobody' | grep -v 'root'| grep -v 'localmgr' ))
declare EntraCount=${#userAccounts[@]}

# Directory location of where the password info is kept
declare SUPPORT_DIR="Library/Application Support"
# Extension of file(s) to look for
declare ENTRA_FILE="com.GiantEagleEntra.plist"

function run_for_each_user ()
{
    user_dir="/Users/$1/$SUPPORT_DIR/$ENTRA_FILE"

    # Extract the PasswordLastChanged field
    password_age=$(/usr/libexec/PlistBuddy -c "Print :PasswordAge" "$user_dir" 2>/dev/null)
    
    [[ $? -ne 0 ]] && exit 1     # Check if the field was found
    if [[ "$EntraCount" -eq 1 ]]; then #only one user on the system
        retval+=$password_age
    else 
        retval+="$1: $password_age"
    fi
}

# Main Script

for user in $userAccounts; do
  run_for_each_user $user
  retval+="
"
done
echo "<result>$retval</result>"
