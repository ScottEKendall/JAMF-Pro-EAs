#!/bin/zsh
# 
# Determine if Rosetta needs installed (AMR only)
#
if [[ $(uname -m) != "arm64" ]] ; then
    result="Intel"
else
    [[ ! $(arch -arch x86_64 uname -m > /dev/null) ]] && result="Yes" || result="No"
fi
echo "<result>$result</result>"
