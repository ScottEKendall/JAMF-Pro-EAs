#!/bin/zsh

declare -a adminUsers
declare -a result

function join { local IFS="$1"; shift; echo "$*"; }
function members { dscl . -list /Users UniqueID | awk '$2 > 499 {print $1}'| while read user; do printf "$user "; dsmemberutil checkmembership -U "$user" -G "$*"; done | grep "is a member" | cut -d " " -f 1; }

adminUsers=$( members "admin" )
results=$(join , ${adminUsers[@]})
#results=$(dscl . -read /Groups/admin GroupMembership | awk -F ":" '{print $2}' | xargs | sed 's/ / | /g')
echo "<result>$results</result>"
