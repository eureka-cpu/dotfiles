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
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  # Opens ports 8096 (HTTP) and 8920 (HTTPS) only on the Tailscale interface (tailscale0),
  # not on your physical NIC. Jellyfin will be unreachable from LAN/WAN.
  #
  # Once both tailscaled and jellyfin are up on pion, access it from any
  # Tailscale node via:
  #   http://pion.your-tailnet.ts.net:8096
  networking = {
    hostName = "pion";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      interfaces."tailscale0".allowedTCPPorts = [ 8096 8920 ];
    };
  };
  # this or --ask-sudo-password every rebuild
  security.sudo.wheelNeedsPassword = false;

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    
    tailscale = {
      enable = true;
      useRoutingFeatures = "client";
      openFirewall = true;
    };

    jellyfin = {
      enable = true;
      # Don't expose anywhere other than tailscale
      openFirewall = false;
    };
  };

  users.users.andrewvious = {
    isNormalUser = true;
    initialPassword = builtins.trace "Reset passwd if flashed: `changeme`" "changeme";
    extraGroups = [ "wheel" "jellyfin" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # asus-rog
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJDzX6wii1D7UR6Rit0zmc7TJQoMitk9YQ3Rp4wXJTr"
      # dev-one
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG5HJekhFhih2epjAwwgVJxna5GKSRQgya5FqaYpM4ZL" 
    ];
  };

  programs.zsh.enable = true;
  environment.systemPackages = [
    pkgs.kitty.terminfo
    pkgs.lm_sensors
  ];

  # Mount external drive, otherwise required on reboot,
  # `nofail` accounts for if drive is unplugged.
  fileSystems."/mnt/external" = {
    device = "/dev/disk/by-uuid/00C6-AEAA";
    fsType = "exfat";
    options = [ "nofail" "umask=007" "uid=0" "gid=${toString config.users.groups.jellyfin.gid}" ];
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "andrewvious" ];
    };
    package = pkgs.nixVersions.latest;
    # Use the path to `nixpkgs` in `inputs` as $NIX_PATH
    nixPath = lib.mkForce [ "nixpkgs=${pkgs.path}" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  systemd.services.jellyfin = {
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
  };

  system.stateVersion = "25.05";
}
