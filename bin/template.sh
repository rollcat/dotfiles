#!/bin/sh
set -eu
PROGRAM="$0"

err() {
    echo >&2 "$@"
}

show_usage() {
    printf >&2 'Usage: %s [-h]\n' "$PROGRAM"
}

show_help() {
    show_usage
    err 'CHANGEME: This is a template for a shell script.'
    err 'Options:'
    err '    -h  Show this help and exit'
}

cleanup() {
    # This code will run when the script is about to exit.
    # Use it to e.g. remove temporary files.
    return
}

main() {
    trap cleanup EXIT INT TERM QUIT
    args=$(getopt "h" $*)
    set -- $args
    while :; do
        case "$1" in
            -h)
                show_help
                exit 0
                ;;
            --)
                shift
                break
                ;;
        esac
    done

    # Your script goes here.

    exit 0
}

main "$@"
