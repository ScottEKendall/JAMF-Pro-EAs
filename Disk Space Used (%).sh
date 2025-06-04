#!/bin/sh
#https://www.jamf.com/jamf-nation/discussions/12546/boot-volume-free-space-ea

DU=$(df -h /Users | awk 'END{ print $(NF-4) }' | tr -d '%' )

# print the reuslts padding with leading 0

echo "<result>$(printf "%02d
" $DU)</result>"
