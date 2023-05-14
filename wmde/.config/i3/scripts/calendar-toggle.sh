#!/bin/sh

app="$1"
if [ -z $app ]; then
    echo "ERROR: no app provided"
    exit
fi

pid=$(ps -a -x -o pid,cmd | grep -E "^[0-9]+ $app"$ | awk '{print $1}')
#echo "==$pid=="
if [ ! -z $pid ]; then
    /usr/bin/kill -s SIGTERM $pid
else
    $app
fi

