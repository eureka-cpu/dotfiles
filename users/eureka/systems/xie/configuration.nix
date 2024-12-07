{ pkgs, lib, ... }:
{
  imports = [
    ../../nixos/configuration.nix
    ../../nixos/laptop-configuration.nix
  ];

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

  hardware.enableRedistributableFirmware = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/SYSTEM_DRV";
      fsType = "vfat";
    };
  };

  # Enable some SysRq keys (80 = sync + process kill)
  # See: https://docs.kernel.org/admin-guide/sysrq.html
  boot.kernel.sysctl."kernel.sysrq" = 80;

  networking.networkmanager.plugins = lib.mkForce [ ];

  hardware.bluetooth.enable = true;

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      font-awesome
      source-han-sans
      source-han-sans-japanese
      source-han-serif-japanese
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Source Han Serif" ];
      sansSerif = [ "Noto Sans" "Source Han Sans" ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
