#/bin/zsh
LOGGED_IN_USER=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
[[ $(id -Gn $LOGGED_IN_USER | grep -o "\badmin\b") ]] && results="Yes" || results="No"
echo "<result>$results</result>"