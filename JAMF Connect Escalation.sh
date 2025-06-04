#!/bin/zsh

# Path to the log file
log_file="/Library/Logs/JamfConnect/UserElevationReasons.log"

# Check if the log file exists
if [ ! -f "$log_file" ]; then
    # If the log file doesn't exist, output a specific message for the extension attribute
    echo "<result>No Jamf Connect privilege elevations</result>"
    exit 0
fi

# Get the most recent 3 entries from the log file
latest_log_entries=$(tail -n 3 "$log_file")

# Begin the result string
recent_times="<result>
"

# Process each log entry
while read log_entry; do
    # Extract the date/time from the log entry
    gmt_date=$(echo $log_entry | awk '{print $1, $2}')
    # Extract the user information from the log entry
    user_info=$(echo $log_entry | cut -d ' ' -f4-)

    # Append the date/time and user information to the result string
    recent_times+="$gmt_date;$user_info
"
done <<< "$latest_log_entries"

# End the result string
recent_times+="</result>"

# Output for Jamf Pro extension attribute
echo -e "$recent_times"
