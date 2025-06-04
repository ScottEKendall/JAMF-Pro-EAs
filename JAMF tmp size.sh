#!/bin/zsh
#
# Calculate the size of the files in JAMF/tmp folder
#
result=""
JAMFtmpfile="/Library/Application Support/JAMF/tmp"

if [[ -f "$JAMFtmpfile" ]]; then
	result=$(du -hc "$JAMFtmpfile" | tail -n1 | cut -f1)
fi

echo "<result>${result}</result>"
