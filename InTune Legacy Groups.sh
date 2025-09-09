#!/bin/zsh

LOGGED_IN_USER=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
SUPPORT_DIR="/Users/$LOGGED_IN_USER/Library/Application Support"
JSS_FILE="$SUPPORT_DIR/com.GiantEagleEntra.plist"
index=0
new_array=()
driveMappings=$(/usr/libexec/PlistBuddy -c "Print DriveMappings" "$JSS_FILE" 2>&1)
if [[ "$driveMappings" == *"Does Not Exist"* ]]; then
    new_array="Unknown"
else
    while true; do
        element=$(/usr/libexec/PlistBuddy -c "Print :DriveMappings:$index" "$JSS_FILE" 2>/dev/null)
        if [[ $? -ne 0 ]]; then
            break # Element does not exist, exit loop
        fi
        new_array+=$(echo $element | xargs )"\n"
        ((index++))
    done
    
fi
[[ -z $new_array ]] && new_array="None"
echo "<result>$new_array</result>"
