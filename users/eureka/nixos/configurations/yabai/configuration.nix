{ config, pkgs, lib, ... }:
{
  imports = [
    ../../../nixos/configuration.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "yabai";

  boot.kernelParams = [
    "apple_dcp.unstable_edid=1" "apple_dcp.show_notch=1"
  ];
  boot.extraModprobeConfig = ''
    options hid_apple iso_layout=0
  '';

  hardware.asahi = {
    enable = true;
    extractPeripheralFirmware = true;
    peripheralFirmwareDirectory = ./firmware;
    setupAsahiSound = true;
  };
  
  boot.binfmt.emulatedSystems = [
    "x86_64-linux"
    "i686-linux"
    "i386-linux"
  ];

  boot.loader.efi.canTouchEfiVariables = false;

  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };
  networking.wireless = {
    enable = false;
    iwd.enable = true;
  };

  programs.hyprland.enable = true;

  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      # Monitor brightness
      { keys = [225]; events = ["key"]; command = "/run/current-system/sw/bin/light -A 5"; }
      { keys = [224]; events = ["key"]; command = "/run/current-system/sw/bin/light -U 5"; }
    ];
  };

  services.auto-cpufreq.enable = true;

  system.stateVersion = "25.05";
}
