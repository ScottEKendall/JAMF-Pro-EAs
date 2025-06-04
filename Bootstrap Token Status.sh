#!/bin/zsh
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

# Checks on if the bootstrap token is supported and escrowed by MDM

# Validating minimum OS version for attribute (10.15.0 or later)
OSVersion=$(sw_vers -productVersion)
OSVersionMajor=$(echo $OSVersion | cut -d '.' -f 1)
OSVersionMinor=$(echo $OSVersion | cut -d '.' -f 2)
if [[ $OSVersionMajor -eq 10 ]] && [[ $OSVersionMinor -lt 15 ]]; then
    echo "<result>Collected for macOS 10.15.0 or later</result>"
    exit 0
fi


StatusBootstrapToken=$(profiles status -type bootstraptoken 2>/dev/null)

if [[ -n $StatusBootstrapToken ]]; then
    Supported='supported on server: YES'
    Escrowed='escrowed to server: YES'
    if [[ "$StatusBootstrapToken" == *"$Supported"* ]] && [[ "$StatusBootstrapToken" == *"$Escrowed"* ]]; then
        Result="Escrowed"
    elif [[ "$StatusBootstrapToken" == *"$Supported"* ]]; then
        Result="Supported"
    else
        Result="Not Supported"
    fi
fi

echo "<result>$Result</result>"
