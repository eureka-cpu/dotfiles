{ pkgs, lib, user, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../../nixos/configuration.nix
    ../../../nixos/laptop-configuration.nix
  ];

  networking.hostName = "dev-one";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-db29127c-e05e-4a4e-8558-2df438c6c766".device = "/dev/disk/by-uuid/db29127c-e05e-4a4e-8558-2df438c6c766";

  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  # Audio settings specific to this machine
  services.pipewire.jack.enable = true;

  # Enabling due to issues with Wayland & screen sharing
  xdg.portal.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  system.stateVersion = "23.11";
}
