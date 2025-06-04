ssid=$( ipconfig getsummary $(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $2}') | awk -F ' SSID : '  '/ SSID : / {print $2}' )
echo "<result>${ssid}</result>"
exit 0
