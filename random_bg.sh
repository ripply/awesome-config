#!/bin/bash
# From http://www.webupd8.org/2009/11/3-lines-script-to-automatically-change.html
# Script to randomly set Background from files in a directory

# Directory Containing Pictures
DIR="${HOME}/Pictures"
if [ -d "$DIR" ]; then
    if [ -d "$DIR/background" ]; then
        DIR="$DIR/background"
    fi
fi

# Command to Select a random jpg file from directory
# Delete the *.jpg to select any file but it may return a folder
PIC=$(ls $DIR/*.jpg | shuf -n1)

echo "$PIC"

# Command to set Background Image
# Gnome2
gconftool -t string -s /desktop/gnome/background/picture_filename $PIC
# Gnome3
gsettings set org.gnome.desktop.background picture-uri file:///"$PIC"
