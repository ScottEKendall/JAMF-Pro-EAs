#!/bin/zsh

declare -a tokenusers
declare -a result

function join { local IFS="$1"; shift; echo "$*"; }

tokenusers=$( fdesetup list | awk -F ',' '{print $1}' )
result=$(join , ${tokenusers[@]})
echo "<result>$result</result>"
