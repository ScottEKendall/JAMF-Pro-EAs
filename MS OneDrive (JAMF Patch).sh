#!/bin/sh
#################################################################
# A script to collect the Bundle Version of Microsoft OneDrive. #
#################################################################

PLIST="/Applications/OneDrive.app/Contents/Info.plist"
KEY="CFBundleVersion"

if [ -f "${PLIST}" ]; then
	RESULT=$(/usr/bin/defaults read "${PLIST}" "${KEY}" 2>/dev/null)
fi

/bin/echo "<result>${RESULT}</result>"

exit 0
