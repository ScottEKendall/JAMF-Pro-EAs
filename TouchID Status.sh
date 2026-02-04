#!/bin/zsh
LOGGED_IN_USER=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
USER_UID=$( id -u "${LOGGED_IN_USER}" )
declare retval=""
function runAsUser () 
{  
    launchctl asuser "$USER_UID" sudo -iu "$LOGGED_IN_USER" "$@"
}

function checkTouchID() {
    local hw="Absent"
    retval="$hw"
    local enrolled="false"
    local bioCount="0"
    # --- Detect Touch ID–capable hardware (internal or external) ---
    bioOutput=$(ioreg -l 2>/dev/null)

    # Check for the device entry indicating hardware presence
    if [[ $bioOutput == *"+-o AppleBiometricSensor"* ]]; then
        hw="Present"
    else
        # Fallback: Parse IOKitDiagnostics for class instance count
        if [[ $bioOutput =~ '"AppleBiometricSensor"=([0-9]+)' && ${match[1]} -gt 0 ]]; then
            hw="Present"
        # Fallback: Magic Keyboard with Touch ID
        elif system_profiler SPUSBDataType 2>/dev/null | grep -q "Magic Keyboard.*Touch ID"; then
            hw="Present"
        fi
    fi

    if [[ "${hw}" == "Present" ]]; then
        # Enrollment check

        bioCount=$(runAsUser bioutil -c 2>/dev/null | awk '/biometric template/{print $3}' | grep -Eo '^[0-9]+$' || echo "0")
        [[ "${bioCount}" -gt 0 ]] && enrolled="true"

        [[ "${enrolled}" == "true" ]] && retval="Enabled" || retval="Not enabled"
    fi
}

checkTouchID
echo "<result>$retval</result>"
