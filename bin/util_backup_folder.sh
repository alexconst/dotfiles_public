#!/bin/bash

function backup() {
    target_folder="${1%/}" # remove any trailing slash
    excludes=""
    shift # discard first argument
    while test $# -gt 0; do
        case "$1" in
            -x)
                shift
                excludes+="--exclude='$1' "
                ;;
            *)
                echo "ERROR: unexpected option? $1"
                break
                ;;
        esac
        shift
    done
    filename="${target_folder}-$(date '+%Y.%m.%d_%H:%M:%S').tar.gz"
    cmd="tar --force-local ${excludes} -czf ${filename} ${target_folder}"
    echo "${cmd}"
    eval "${cmd}"
}


if [[ $# -eq 0 ]]; then
    echo "ABOUT: backup a single folder to a tar file, whose name automatically includes a timestamp, while providing the option to exclude items (via option -x)"
    echo "EXAMPLE: du -sh myfolder/*  ;  backup myfolder -x myfolder/tmp -x '*.pdf'"
    return 1
fi


backup "$@"

