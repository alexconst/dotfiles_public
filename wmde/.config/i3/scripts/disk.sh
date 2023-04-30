#!/usr/bin/env sh
DIR="${DIR:-$BLOCK_INSTANCE}"
DIR="${DIR:-$HOME}"
ALERT_LOW="${ALERT_LOW:-$1}"
ALERT_LOW="${ALERT_LOW:-90}" #  color will turn red above this value (default: 90%) --- ignored

LOCAL_FLAG="-l"
if [ "$1" = "-n" ] || [ "$2" = "-n" ]; then
    LOCAL_FLAG=""
fi

df -h -P $LOCAL_FLAG "$DIR" | awk -v label="$LABEL" -v alert_low=$ALERT_LOW '
/\/.*/ {
	# full text
    print label "(" $4 " free)"
	use=$5
	# no need to continue parsing
	exit 0
}
END {
	gsub(/%$/,"",use)
	if (use > 90) {
		print("#FF0000")
	} else if (use > 80) {
		print("#FFAE00")
	} else if (use > 70) {
		print("#FFF600")
	}
}
'

