#!/bin/sh
### Base settings: take from .profile
. ~/.profile

### Preferences
if [ -r ~/.Xresources ]
then xrdb -merge ~/.Xresources
fi

set-wallpaper

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
if [ -z "${DBUS_SESSION_BUS_ADDRESS}" ] && has dbus-launch
then eval $(dbus-launch --sh-syntax --exit-with-x11)
fi

xlock=$(which slock xlock 2>/dev/null)
if has xidle && [ -n "${xlock}" ]
then xidle -timeout 600 -program "${xlock}" &
fi

# Firefox
export MOZ_ACCELERATED=1
export MOZ_WEBRENDER=1

wm=$(which quartz-wm i3 dwm awesome cwm x-window-manager xterm false 2>/dev/null | head -1)
if has ck-launch-session
then wm="ck-launch-session $wm"
fi
exec $wm
