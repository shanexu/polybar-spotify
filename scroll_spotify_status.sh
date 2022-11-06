#!/bin/bash

# see man zscroll for documentation of the following parameters
zscroll -l 30 \
        -U 1 \
        --scroll-padding "  " \
        --delay 0.4 \
        --match-command "`dirname $0`/get_spotify_status.sh --status" \
        --match-text "Playing" "--scroll 1" \
        --match-text "Paused" "--scroll 0" \
        --update-check true "`dirname $0`/get_spotify_status.sh" &

wait

