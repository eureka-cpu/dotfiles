# NixOS x Hyprland x eww

The end goal of this project is to eventually have a
desktop environment that can be imported from a nix flake.
I'd like to be able to import the flake and have the
desktop environment produced with just one line. At
the moment, my setup is more just an amalgamation of
my personal preferences and packages I use daily. Once
this project reaches the point of a fully fleshed out
environment with widgets, etc, I'll move it into its
own repository and have my dotfiles just be the remaining
nixpkgs that I use for my systems.

## Motivation

There are a ton of great options to look at for creating
your personalized dotfiles, which is a double-edged sword.
It can be extremely hard to find everything you're looking
for. In a way, I'd like this to be a very simple and modular
nix-box so to speak. You can drop in the flake and it will
load up the widgets and desktop environment, as if you were
using any other; Gnome, etc. This is not only an experiment
for my own education of the nix ecosystem, but also for posterity,
for anyone who wants to do the same, to have an example of
what it might look like.

## Progress

I'm creating this for my own use cases, and I don't have need
of many widgets, but I would like to eventually expand upon
this list.

- [x] setup
  - [x] main flake
- [x] nix-colors
- [x] widgets (eww)
  - [x] top-bar
  - [x] launcher
  - [x] powermenu

- [ ] dots
  - [x] home-manager
  - [ ] snowfall
  - [x] hyprland.conf
  - [x] start.sh

- [ ] hyprland
  - [ ] plugins
    - [ ] hyprlock
    - [ ] hyprcursor
  - [ ] home-manager module
  - [ ] nix hyprland.conf
