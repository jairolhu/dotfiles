#!/bin/sh

xrandr --output Virtual-1 --mode 1920x1080 &
nitrogen --restore
ibus-daemon -rxRd
systemctl restart systemd-timesyncd
