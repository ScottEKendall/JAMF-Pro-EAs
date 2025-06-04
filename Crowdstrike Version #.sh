#!/bin/zsh

RESULT="Not Installed"

if [ -d "/Applications/Falcon.app" ] ; then
    
    RESULT=$( /Applications/Falcon.app/Contents/Resources/falconctl stats | awk '/version/ {print $2}')
    
fi

echo "<result>$RESULT</result>"
