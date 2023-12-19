#!/bin/sh

# This script uses mpstat to print the CPU load

CPU_LOAD=$(mpstat 1 1 | awk '/Average/ {printf "%.0f\n", 100.0-$NF}')
printf "%s%%\n" $CPU_LOAD
if [ $CPU_LOAD -ge 80 ]; then
  printf "#FF0000\n"
elif [ $CPU_LOAD -ge 50 ]; then
  printf "#FFFC00\n"
else
  printf "#EBDBB2\n"
fi

