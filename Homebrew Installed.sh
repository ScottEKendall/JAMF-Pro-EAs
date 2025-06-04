#!/bin/zsh

# Extension attribute for homebrew install

[[ "$(uname -p)" == "arm" ]] && brewPath="/opt/homebrew" || brewPath="/usr/local"
[[ -e "${brewPath}/bin/brew" ]] && RESULT="Yes" || RESULT="No"
echo "<result>$RESULT</result>"
