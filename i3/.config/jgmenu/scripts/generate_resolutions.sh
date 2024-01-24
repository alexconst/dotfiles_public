#!/bin/bash

# This script is unnecessary. Having a jgmenu config with lxrandr is enough. Only keeping this script for future reference.

datadir="$HOME/.config/jgmenu"
filename="${datadir}/resolutions.csv"

# Ensure folder exists
mkdir -p "${datadir}"

# Clear the existing CSV file
> "${filename}"

# add convenient entry
echo "lxrandr,lxrandr,video-display" >> "${filename}"

# Parse the output of xrandr -q
res_regex="^[[:space:]]+[0-9]+x[0-9]+[[:space:]]"
while IFS= read -r line; do
    # Extract the monitor name and resolution
    if [[ $line == *"connected"* ]]; then
        monitor=$(echo $line | awk '{print $1}')
    elif [[ $line =~ $res_regex ]]; then
        resolution=$(echo $line | awk '{print $1}')
        echo "$monitor @ $resolution,sh -c \"xrandr --output $monitor --mode $resolution\",video-display" >> "${filename}"
    fi
done < <(xrandr -q)

