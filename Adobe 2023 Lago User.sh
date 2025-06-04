#!/bin/zsh
lagoUser="No"
if [[ -d "/Applications/Adobe InDesign 2023/Adobe InDesign 2023.app/Contents/MacOS/Plug-Ins/Lago" ]]; then
	lagoUser="Yes"
fi
echo "<result>$lagoUser</result>"
