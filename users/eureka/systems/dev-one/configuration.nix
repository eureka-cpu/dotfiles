{ pkgs, musnix, lib, user, ... }:
let
  gpu_drivers = [ "amdgpu" "radeon" ];
in
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/configuration.nix
    ../../nixos/laptop-configuration.nix
  ];

  boot.initrd.luks.devices."luks-db29127c-e05e-4a4e-8558-2df438c6c766".device = "/dev/disk/by-uuid/db29127c-e05e-4a4e-8558-2df438c6c766";

  # Enable the X11 windowing system.
  services.xserver = {
    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  services.displayManager = {
    # Enable automatic login for the user.
    autoLogin.enable = lib.mkForce true;
    autoLogin.user = user.name;
  };
  # Workaround for GNOME autologin
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  # Extra GPU settings
  boot.initrd.kernelModules = gpu_drivers;
  services.xserver.videoDrivers = gpu_drivers;

  # Audio settings specific to this machine
  services.pipewire.jack.enable = true;
  musnix = {
    enable = true;
    rtcqs.enable = true;
    soundcardPciId = "03:00.1";
  };

  # Enabling due to issues with Wayland & screen sharing
  xdg.portal.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    gnome.excludePackages = with pkgs; [
      cheese
      gnome.gnome-music
      gnome-tour
      epiphany
      geary
      gnome-text-editor
      gnome.gnome-contacts
      yelp
    ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
