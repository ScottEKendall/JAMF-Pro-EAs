#!/bin/sh

AdminAccount="localmgr"

jamfAdminToken=$(sysadminctl -secureTokenStatus $AdminAccount 2>&1 | awk '{print$7}')

[[ "${jamfAdminToken}" == "ENABLED" ]] && result="True" || result="False"

echo "<result>$result</result>"
