#!/bin/zsh
#
# Author  : Perry Driscoll - https://github.com/PezzaD84
# Created : 25/4/2023
# Updated : 25/4/2023
# Version : v1
#
#########################################################################################
# Description:
#			  Extension attribute to display the admin account ID
#
#########################################################################################
# Copyright © 2023 Perry Driscoll <https://github.com/PezzaD84>
#
# This file is free software and is shared "as is" without any warranty of 
# any kind. The author gives unlimited permission to copy and/or distribute 
# it, with or without modifications, as long as this notice is preserved. 
# All usage is at your own risk and in no event shall the authors or 
# copyright holders be liable for any claim, damages or other liability.
#########################################################################################

LAPSLOG="/Library/Application Support/GiantEagle/logs/LAPS.log"

LAPS_ADMIN_ID=$(head -6 "${LAPSLOG}" | grep "does not exist" | awk '{print $1}')

echo "<result>${LAPS_ADMIN_ID}</result>"
