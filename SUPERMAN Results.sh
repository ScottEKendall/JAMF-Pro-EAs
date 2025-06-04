#!/bin/zsh

# Path to the super working folder:
SUPER_FOLDER="/Library/Management/super"
results=""
error=$(tail -5 "$SUPER_FOLDER/super.log" | grep "failed" | awk -F ":" '{print $5}')
if [[ ! -z $error ]]; then
	results="Error"
else
	results="Successful"
fi
echo "<result>$results</result>"
exit 0
