#!/bin/sh

picom &
xrandr --output Virtual-1 --mode 1920x1080 &
nitrogen --restore &
ibus-daemon -rxRd
