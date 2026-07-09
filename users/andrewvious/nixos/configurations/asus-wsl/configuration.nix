{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    inputs.nixos-wsl.nixosModules.wsl
  ];

  networking.hostName = "asus-wsl";
  nixpkgs.hostPlatform = "x86_64-linux";

  wsl.enable = true;
  wsl.defaultUser = "andrewvious";

  environment.systemPackages = with pkgs; [ git ];

  programs.zsh.enable = true;
  users.users.andrewvious.shell = pkgs.zsh;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
