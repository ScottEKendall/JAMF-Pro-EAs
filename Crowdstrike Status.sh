#!/bin/zsh

RESULT="Not Installed"
FalconApp="/Applications/Falcon.app"
#if [[ -d  ${FalconApp} ]] ; then
    RESULT=$(${FalconApp}/Contents/Resources/falconctl stats | grep "State:" | head -n 1 | awk '{print $2}')
#fi
echo "<result>$RESULT</result>"
