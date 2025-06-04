#!/bin/sh

RESULT="Not Installed"

if [ -d "/Applications/Falcon.app" ] ; then
    
    RESULT=$( /Applications/Falcon.app/Contents/Resources/falconctl stats | awk '/Cloud Activity | Last Established At/ {print $4,$5,$6,$8,$9}' )
    
fi

echo "<result>$RESULT</result>"
