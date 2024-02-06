#!/bin/bash

# ISSUES:
# - the only way to stop the lock process is by pressing the Esc key. No other key nor mouse move or button will work. That is a feh limitation.
# - there is a race condition between notify-send and feh. feh is too slow
# - the notify-send popup will linger until the timeout unless you click on it. ie, pressing Esc won't remove it


timeout="$1"
locker="${@:2} -n"              # make i3lock run without forking
image="${@: -1}"


function error_msg() {
    message="$@"
    xmessage -geometry 200x200 -center -buttons EXIT:1  "$message"
}

unset msg
if [[ -z "$timeout" ]]; then
    msg="no timeout provided"
elif [[ ! -f "$image" ]]; then
    msg="no such image: $image"
elif [[ ! $locker =~ i3lock ]]; then
    msg="invalid i3locker command"
fi
if [[ -n "$msg" ]]; then
    echo "$(date) DEBUG: $msg" >> /tmp/tmp.txt
    error_msg "$msg"
    exit 1
fi


echo "$(date) DEBUG: timeout = $timeout" >> /tmp/tmp.txt
echo "$(date) DEBUG: image = $image" >> /tmp/tmp.txt
echo "$(date) DEBUG: locker = $locker" >> /tmp/tmp.txt

# Run feh in fullscreen mode in the background
feh --fullscreen --zoom 100 "${image}" &
echo "$(date) DEBUG: launched feh" >> /tmp/tmp.txt
# Get the process ID of feh
pid=$!
# NOTE: race condition... when avoiding feh to obscure notify-send
sleep 1s

# NOTE: this logic actually doesn't work because notify-send is short lived, ie it's process finishes even though the pop up persists
# Leaving this logic here with the hope it may be fixed with future notify-send versions
notid=$(notify-send --transient --expire-time ${timeout}000 "PSA" "Will lock screen in $timeout seconds... Press Esc to abort" -p)
#pidnot=$!
# wait for $timeout seconds before locking screen and if the user acts then kill the message popup
elapsed_time=0
while [[ $elapsed_time -lt $timeout ]]; do
    sleep 1
    let elapsed_time+=1
    if [[ ! -d /proc/$pid ]]; then
        # if feh was closed then:
        #kill $pidnot            # close notify-send popup
        notify-send --transient --expire-time 1 "PSA" "Will lock screen in $timeout seconds... Press Esc to abort" -r $notid
        break                   # break loop
    fi
done

# if feh is still running after the timeout then we screen lock
if [[ -d /proc/$pid ]]; then
    eval $locker                # run i3lock
    kill $pid                   # kill feh
fi


