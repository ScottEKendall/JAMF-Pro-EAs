#!/bin/zsh

#Determine model
arch=$(/usr/bin/arch)
model=$(system_profiler SPHardwareDataType | grep "Model Name:" | cut -d ' ' -f 9)

if [[ ! "$model" =~ "Book" ]]; then
    echo "<result>Not A Laptop</result>"
    return 0
fi

if [[ "$arch" == "arm64" ]]; then
    capacity=$(system_profiler SPPowerDataType | grep "Maximum Capacity:" | sed 's/.*Maximum Capacity: //')
    echo "<result>$(system_profiler SPPowerDataType | grep "Condition:" | sed 's/.*Condition: //') ($capacity)</result>"
else
    echo "<result>$(system_profiler SPPowerDataType | grep "Condition:" | sed 's/.*Condition: //')</result>"
fi
