#!/usr/bin/env bash

# init wallpaper daemon & set wallpaper
sleep 2; swww init & swww img ~/Wallpapers/gruvbox-mountain-village-6k.jpg &

nm-applet --indicator &

# notification daemon
mako
