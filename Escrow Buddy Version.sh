#!/bin/bash

BUNDLE_PATH="/Library/Security/SecurityAgentPlugins/Escrow Buddy.bundle"
VERSION_KEY="CFBundleShortVersionString"

if [ -f "$BUNDLE_PATH/Contents/Info.plist" ]; then
    RESULT=$(defaults read "$BUNDLE_PATH/Contents/Info.plist" "$VERSION_KEY")
else
    RESULT="Not Installed"
fi

echo "<result>$RESULT</result>"
