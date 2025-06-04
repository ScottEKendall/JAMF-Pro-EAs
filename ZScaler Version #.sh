#!/bin/zsh
# 
AppName="/Applications/ZScaler/ZScaler.app"

Version=$(defaults read $AppName/Contents/Info.plist CFBundleShortVersionString)
echo "<result>$Version</result>"
