{ config, pkgs, lib, user, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../../nixos/configuration.nix
    ../../../nixos/laptop-configuration.nix
    ../../../nixos/greetd.nix
  ];

  networking.hostName = "dev-one";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-db29127c-e05e-4a4e-8558-2df438c6c766".device = "/dev/disk/by-uuid/db29127c-e05e-4a4e-8558-2df438c6c766";

  # Hyprland
  programs.hyprland = {
    enable = true;
    package = with pkgs; builtins.trace "Built against Hyprland v${hyprland.version}" hyprland;
  };

  # Audio settings specific to this machine
  services.pipewire.jack.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  system.stateVersion = "23.11";
}
