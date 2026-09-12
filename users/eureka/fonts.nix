# Shared between NixOS and Darwin configs for this user (both module systems
# expose `fonts.packages`). Host-specific font needs (e.g. icon fonts for a
# particular status bar, or a notation font only used on one machine) still
# belong in that host's own configuration.nix.
{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    julia-mono # broad unicode coverage, used as a fallback for missing glyphs
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    source-han-sans
    source-han-serif
  ];
}
