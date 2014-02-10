#!/bin/bash
    PICTURES=`echo ~`/Pictures
    if [ -d "$PICTURES" ] || mkdir "$PICTURES"; then
        cd "$PICTURES"
    else
        # cd to directory that script is run in otherwise
        DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
        cd "$DIR"
    fi
    RANDOM_FILENAME=`tr -dc A-Za-z0-9_ < /dev/urandom | head -c8`
    wget -U "Mozilla/5.0" -O - http://interfacelift.com/wallpaper_beta/downloads/random/hdtv/ | grep download.png | sed 's/^\s*<a href="\([^"]\+\)"><[^>]\+download.*$/http:\/\/www.interfacelift.com\1/' | head -n 1 | wget -U "Mozilla/5.0" -i - -O wallpaper.jpg.tmp
    mv wallpaper.jpg.tmp $RANDOM_FILENAME.jpg
#feh
    #feh --bg-scale ${PWD}/wallpaper.jpg
#Gnome2
    #gconftool-2 -t str --set /desktop/gnome/background/picture_filename ${PWD}/wallpaper.jpg
#Gnome3
    gsettings set org.gnome.desktop.background picture-uri file:///${PWD}/$RANDOM_FILENAME.jpg
#XFCE
    #xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s ${PWD}/wallpaper.jpg
