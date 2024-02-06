#!/bin/bash

# ISSUES:
# - the only way to stop the lock process is by pressing the Esc key. No other key nor mouse move or button will work. That is a feh limitation.
# - there is a race condition between notify-send and feh. feh is too slow, so the popup may not be visible on some random occasion


TIMEOUT_SECS="$1"
LOCKER="${@:2} --nofork"
IMAGE="${@: -1}"
logfile="/tmp/screen-lock.log"

function error_msg() {
    local msg="$@"
    xmessage -geometry 200x200 -center -buttons EXIT:1  "$msg"
}

function logger_debug() {
    return # NOTE: disabled

    local msg="$@"
    echo "$(date) DEBUG: $msg" >> $logfile
}

function display_image_fullscreen() {
    local image="$1"
    # launch feh process in the background, to display image in fullscreen mode as a preview of the screenlock itself
    feh --fullscreen --zoom 100 "${image}" &
    # Get the process ID of feh
    FUN_RET=$!
    logger_debug "launched feh"
}

function notify() {
    # because notify-send is short lived, ie the process finishes while the popup itself persists, we can't use the pid, but we can workaround it using its notification id
    local timeout_secs="$1"
    local action="$2"   # can be: print, replace
    local handle="$3"
    if [[ "$action" == "print" ]]; then
        timeout_ms="${timeout_secs}000"
        action="-p"
    elif [[ "$action" == "replace" ]]; then
        timeout_ms=1
        action="-r $handle"
    else
        msg="invalid operation: $action"
        logger_debug "$msg"
        error_msg "$msg"
    fi
    logger_debug "notify action: $action"
    FUN_RET=$(notify-send --transient --expire-time ${timeout_ms} "PSA" "Will lock screen in $timeout_secs seconds... Press Esc to abort" $action)
    logger_debug "notify output: $FUN_RET"
}

unset msg
if [[ -z "$TIMEOUT_SECS" ]]; then
    msg="no timeout provided"
elif [[ ! -f "$IMAGE" ]]; then
    msg="no such image: $IMAGE"
elif [[ ! $LOCKER =~ i3lock ]]; then
    msg="invalid i3locker command"
fi
if [[ -n "$msg" ]]; then
    logger_debug "$msg"
    error_msg "$msg"
    exit 1
fi


logger_debug "timeout = $TIMEOUT_SECS"
logger_debug "image = $IMAGE"
logger_debug "locker = $LOCKER"


# display full screen image
display_image_fullscreen "$IMAGE"
pid_feh=$FUN_RET

# because notify-send is faster than feh it would get occluded by it, one fix is to just wait, but notice this makes for a race condition
sleep 1s
# show popup saying it will lock the screen
notify "$TIMEOUT_SECS" "print"
nid_notify=$FUN_RET

# wait for $timeout seconds before locking screen and if the user acts then kill the message popup
elapsed_time=0
while [[ $elapsed_time -lt $TIMEOUT_SECS ]]; do
    sleep 1
    let elapsed_time+=1
    if [[ ! -d /proc/$pid_feh ]]; then
        # if feh was closed then we can also terminate the popup notification
        notify "$TIMEOUT_SECS" "replace" "$nid_notify"
        break
    fi
done

# if feh is still running after the timeout then we screen lock
if [[ -d /proc/$pid_feh ]]; then
    eval $LOCKER                # run i3lock
    kill $pid_feh               # kill feh
fi


