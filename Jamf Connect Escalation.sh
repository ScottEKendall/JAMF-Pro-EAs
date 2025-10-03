#!/bin/zsh
# Path to the log file 
log_file="/Library/Logs/JamfConnect/UserElevationReasons.log" 

# Check if the log file exists 
if [[ ! -f "$log_file" ]]; then # If the log file doesn't exist, output a specific message for the extension attribute 
    echo "<result>No Jamf Connect privilege elevations</result>" 
    exit 0
fi 
# Get the most recent 3 entries from the log file 
latest_log_entries=$(tail -n 3 "$log_file") 
# Begin the result string recent_times="<result>\\n" 
# Process each log entry 

echo "$latest_log_entries" | while read log_entry; do
    # Extract the date/time from the log entry 
    gmt_date=$(echo $log_entry | awk '{print $1, $2}') 
    # Convert GMT to Eastern Time 
    eastern_date=$(date -jf "%Y-%m-%d %H:%M:%S" -v"-5H" "$gmt_date" "+%Y-%m-%d %H:%M:%S") 
    # Check if Daylight Saving Time is in effect 
    daylight_saving=$(date -v"-5H" -jf "%Y-%m-%d %H:%M:%S" "$gmt_date" "+%Z") 
    if [ "$daylight_saving" = "EDT" ]; then 
        eastern_date=$(date -jf "%Y-%m-%d %H:%M:%S" -v"-4H" "$gmt_date" "+%Y-%m-%d %H:%M:%S") 
    fi 
    # Extract the user information from the log entry 
    user_info=$(echo $log_entry | cut -d ' ' -f4-) 
    # Append the date/time and user information to the result string 
    recent_times+="$eastern_date $user_info\\n" 
done # End the result string recent_times+="</result>" # Output for Jamf Pro extension attribute 

echo "<result>$recent_times</result>"