#!/bin/bash

# count how many updates we have got
ups=`apt list --upgradable |& grep -v 'Listing\|WARNING\|^$' | wc -l`

# print the results
if [ "$ups" -eq "1" ]; then
    echo "(1 update)"
elif [ "$ups" -gt "1" ]; then
    echo "($ups updates)"
elif [ -f /var/run/reboot-required ]; then
    echo "(reboot required)"
else
    echo "(up to date)"
fi

