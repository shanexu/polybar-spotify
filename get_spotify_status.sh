#!/bin/bash

# Set the source audio player here.
# Players supporting the MPRIS spec are supported.
# Examples: spotify, vlc, chrome, mpv and others.
# Use `playerctld` to always detect the latest player.
# See more here: https://github.com/altdesktop/playerctl/#selecting-players-to-control
QQ_MUSIC_PID=$(pgrep -f '^/usr/lib/electron.*/electron.*/usr/lib/qqmusic/app.asar$')
PLAYER="chromium.instance${QQ_MUSIC_PID}"
# PLAYER=playerctld

# $1 module, $2 hook
update_module_hooks() {
    polybar-msg action "#$1.hook.$2" 1>/dev/null 2>&1
}

if [ -z "$QQ_MUSIC_PID" ]; then
    # echo '%{T3}鈴%{T-}'
    echo ''
    update_module_hooks spotify-prev 1
    update_module_hooks spotify-next 1
    update_module_hooks spotify-play-pause 2
    exit
fi

CMD=$1
if [ ! -z $CMD ] && [ "$CMD" != "--status" ]; then
    playerctl --player=$PLAYER $CMD
    exit
fi

# Format of the information displayed
# Eg. {{ artist }} - {{ album }} - {{ title }}
# See more attributes here: https://github.com/altdesktop/playerctl/#printing-properties-and-metadata
FORMAT="{{ title }} - {{ artist }}"

# The name of polybar bar which houses the main spotify module and the control modules.
# PARENT_BAR="topbar"
# PARENT_BAR_PID=$(pgrep -a "polybar" | grep "$PARENT_BAR" | cut -d" " -f1)

# Sends $2 as message to all polybar PIDs that are part of $1
# update_hooks() {
#     while IFS= read -r id
#     do
#         polybar-msg -p "$id" action "#spotify-play-pause.hook.$2" 1>/dev/null 2>&1
#     done < <(echo "$1")
# }

PLAYERCTL_STATUS=$(playerctl --player=$PLAYER status 2>/dev/null)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    STATUS=$PLAYERCTL_STATUS
else
    STATUS='%{T3}鈴%{T-}'
fi

if [ "$1" == "--status" ]; then
    echo "$STATUS"
    # echo ''
else
    if [ "$STATUS" = "Stopped" ]; then
        echo "No music is playing"
    elif [ "$STATUS" = "Paused"  ]; then
        update_module_hooks spotify-prev 0
        update_module_hooks spotify-next 0
        update_module_hooks spotify-play-pause 1
        playerctl --player=$PLAYER metadata --format "$FORMAT"
    elif [ "$STATUS" = '%{T3}鈴%{T-}'  ]; then
        update_module_hooks spotify-prev 0
        update_module_hooks spotify-next 0
        update_module_hooks spotify-play-pause 1
        echo "$STATUS"
        # echo ''
    else
        update_module_hooks spotify-prev 0
        update_module_hooks spotify-next 0
        update_module_hooks spotify-play-pause 0
        playerctl --player=$PLAYER metadata --format "$FORMAT"
    fi
fi

