#!/bin/zsh
results="Not Finished"
enrollmentFile="/Library/Application Support/GiantEagle/Enrollment/.GiantEagleSetupDone"
[[ -e $enrollmentFile ]] && results="Enrolled"
echo "<result>$results</result>"
