#!/bin/sh
### Some login shells (like ksh) need $ENV to read their .*rc
case "$(getent passwd $(id -un) | cut -d: -f7)" in
    */ksh)
        export ENV=$HOME/.kshrc
        ;;
    */mksh)
        export ENV=$HOME/.mkshrc
        ;;
esac

### Base settings: take from .profile
. ~/.profile

### Preferences
if [ -r ~/.Xresources ]
then xrdb -merge ~/.Xresources
fi

~/bin/set-wallpaper

# Turn off audible bell
xset -b

### Fonts
xset fp default
if [ -d /usr/local/share/fonts ]
then
    find /usr/local/share/fonts -name fonts.dir \
        | xargs -n1 dirname \
        | xargs -n1 xset +fp
    xset fp rehash
fi

### Input
# OpenBSD: activate scroll wheel button
if [ -c /dev/wsmouse ]
then
    xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation" 1
    xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation Axes" 6 7 4 5
    xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation Button" 2
    xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation Timeout" 200
    xinput set-prop "/dev/wsmouse" "WS Pointer Wheel Emulation Inertia" 3
fi

# Natural scrolling
for id in $(xinput list --id-only)
do
    if xinput --list-props $id \
        | grep -q "libinput Natural Scrolling Enabled"
    then
        xinput set-int-prop $id \
            "libinput Natural Scrolling Enabled" 8 1
    fi
done

# Remap caps lock to control
setxkbmap -option ctrl:nocaps

### Desktop and apps
if [ -x /usr/local/bin/dbus-launch -a -z "${DBUS_SESSION_BUS_ADDRESS}" ]; then
    eval $(dbus-launch --sh-syntax --exit-with-x11)
fi

if has xidle && has xlock
then
    xidle \
        -timeout 600 \
        -program "xlock -mode blank -lockdelay 10 -timeelapsed" &
fi

if has syncthing
then syncthing --no-browser &
fi

# Firefox
export MOZ_ACCELERATED=1
export MOZ_WEBRENDER=1

LOCATION=48.2:16.3667  # Vienna, AT
if has redshift
then
    redshift -x
    redshift -P -l $LOCATION -t 6500:5500 &
fi

if has ck-launch-session
then exec ck-launch-session $WM
else exec $WM
fi
