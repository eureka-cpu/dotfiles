{ config, pkgs, lib, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  networking = {
    hostName = "pion";
    networkmanager.enable = true;
  };

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    openFirewall = true;
  };

  users.users.andrewvious = {
    isNormalUser = true;
    initialPassword = builtins.trace "Please change inital passwd, current: changeme" "changeme";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # asus-rog
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJDzX6wii1D7UR6Rit0zmc7TJQoMitk9YQ3Rp4wXJTr"
      # dev-one
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG5HJekhFhih2epjAwwgVJxna5GKSRQgya5FqaYpM4ZL" 
    ];
  };

  programs.zsh.enable = true;
  environment.systemPackages = [ pkgs.kitty.terminfo ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "andrewvious" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  system.stateVersion = "25.05";
}
