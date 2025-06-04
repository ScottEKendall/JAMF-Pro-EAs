#!/bin/zsh
function join { local IFS="$1"; shift; echo "$*"; }
apps=$(find /Applications -name "Adobe*" -type d -maxdepth 1 | sed 's|^/Applications/||'| grep -v "^Adobe Creative Cloud$" | grep -v "Adobe Acrobat*" | grep -v "^Adobe Experience Manager*" |  grep -v "^Adobe Digital Editions*" | sort)
results=$(join , ${apps[@]})
echo "<result>$results</result>"
