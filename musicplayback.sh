#! /bin/bash

# Used in my awesomewm rc.lua to control music depending on what is currently running
# script to control music playing for audacious and rhythmbox

COMMAND="$1"

isrunning () {
    #search pgrep for something that is not us
    for PID in `pgrep -f $1`; do
        if [ $PID -eq $$ ]; then
	    echo found this pid
        else
	    #found something else that is not us
	    #exit, its already running
	    return 0
        fi
    done
    #its not running...
    return 1
}

if isrunning audacious; then
    if [ "$COMMAND" == 'play' ]; then
        audacious -t
    elif [ "$COMMAND" == 'prev' ]; then
        audacious -r
    elif [ "$COMMAND" == 'next' ]; then
        audacious -f
    elif [ "$COMMAND" == 'stop' ]; then
        audacious -s
    else
        echo 'audacious: unknown command ' "$COMMAND"
    fi
elif isrunning rhythmbox; then
    if [ "$COMMAND" == 'play' ]; then
        rhythmbox-client --play-pause
    elif [ "$COMMAND" == 'prev' ]; then
        rhythmbox-client --previous
    elif [ "$COMMAND" == 'next' ]; then
        rhythmbox-client --next
    elif [ "$COMMAND" == 'stop' ]; then
        rhythmbox-client --pause
    else
        echo 'rhythmbox: unknown command ' "$COMMAND"
    fi
else
    if [ -z "$2" ]; then
        #audacious -p
	rhythmbox&
	sleep 2 && rhythmbox-client --play
    fi
fi
    
