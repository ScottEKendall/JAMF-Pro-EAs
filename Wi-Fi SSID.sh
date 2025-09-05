ssid=$( system_profiler SPAirPortDataType | awk '/Current Network Information:/ { getline; print substr($0, 13, (length($0) - 13)); exit }' )
echo "<result>${ssid}</result>"
exit 0
