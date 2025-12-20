{ pkgs, lib, user, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ../../nixos/configuration.nix
      ../../nixos/laptop-configuration.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-04f2d713-cd4e-4d6e-bb67-024a40dd176a".device = "/dev/disk/by-uuid/04f2d713-cd4e-4d6e-bb67-024a40dd176a";

  # Loads the drivers for AMD GPUs on boot
  services.xserver.videoDrivers = [ "amdgpu" "radeon" ];
  boot.initrd.kernelModules = [ "amdgpu" "radeon" ];
  
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Audio settings specific to this machine
  services.pipewire.jack.enable = true;

  # Enabling due to issues with Wayland & screen sharing
  xdg.portal.enable = true;
  
  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "andrewvious";

  # Workaround for GNOME autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {   
    gnome.excludePackages = with pkgs; [
      cheese
      gnome-music
      gnome-tour
      epiphany
      geary
      gedit
      gnome-text-editor
      gnome-contacts
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
