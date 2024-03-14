#!/usr/bin/env bash

# init wallpaper daemon & set wallpaper
sleep 3; swww init & swww img ~/Wallpapers/witch-queen-02.jpg &

eww daemon -c ~/Code/mynixui/eww & eww open window -c ~/Code/mynixui/eww &

nm-applet --indicator &

# notification daemon
mako
