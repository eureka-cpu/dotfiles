{ pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../../nixos/configuration.nix
    ../../../nixos/laptop-configuration.nix
  ];

  networking.hostName = "xie";
  services.xserver.displayManager.startx.enable = true;

  # Must be enabled to use sway with home-manager
  security.polkit.enable = true;

  boot.loader.systemd-boot = {
    enable = true;

    # The default EFI partition created by Windows is really small, limit to 2
    # generations to be on the safe side.
    configurationLimit = 2;
  };

  boot.initrd.systemd = {
    enable = true;

    # This is not secure, but it makes diagnosing errors easier.
    emergencyAccess = true;
  };

  networking.networkmanager.plugins = lib.mkForce [ ];

  hardware.bluetooth.enable = true;

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      font-awesome
      source-han-sans
      source-han-serif
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Source Han Serif" ];
      sansSerif = [ "Noto Sans" "Source Han Sans" ];
    };
  };

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "25.05";
}
