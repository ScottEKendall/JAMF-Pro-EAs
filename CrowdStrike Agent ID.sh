#!/bin/zsh

result="Not Installed"
falconApp="/Applications/Falcon.app"

[[ -d "${falconApp}" ]] && result=$( ${falconApp}/Contents/Resources/falconctl stats | awk '/agentID/ {print $2}' )
    
echo "<result>$result</result>"
