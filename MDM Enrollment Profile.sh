#!/bin/zsh
retval="Profile current"
validateresults=$(sudo profiles validate -type enrollment)
if [[ -z $( echo $validateresults | grep "appears to match") ]]; then
    retval="Profile outdated"
fi
echo "<result>$retval</result>"
