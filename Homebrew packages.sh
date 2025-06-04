#!/bin/zsh
# Extension attribute for homebrew installed packages

LOGGED_IN_USER=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
[[ "$(uname -p)" == "arm" ]] && brewPath="/opt/homebrew" || brewPath="/usr/local"

if [[ -e "${brewPath}/bin/brew" ]]; then
	tmp=$(sudo -u "$LOGGED_IN_USER" ${brewPath}/bin/brew leaves -r)
	RESULT=$tmp" "$(ls ${brewPath}/Caskroom)
    # If the results are empty from the above locations, then dump the entire Cellar directory
    [[ -z $RESULT ]] && RESULT=$(ls ${brewPath}/Cellar)
else
	RESULT=""
fi

echo "<result>$RESULT</result>"
