{ pkgs, lib, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ../../../nixos/configuration.nix
      ../../../nixos/laptop-configuration.nix
      ../../../nixos/nordvpn.nix
    ];

  networking.hostName = "dev-one";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-04f2d713-cd4e-4d6e-bb67-024a40dd176a".device = "/dev/disk/by-uuid/04f2d713-cd4e-4d6e-bb67-024a40dd176a";

  # Loads the drivers for AMD GPUs on boot
  services.xserver.videoDrivers = [ "amdgpu" "radeon" ];
  boot.initrd.kernelModules = [ "amdgpu" "radeon" ];
  
  # Enable GDM for keyring management & niri compositor
  services.displayManager.gdm.enable = true;
  programs.niri.enable = true;

  # Battery statistics
  services.upower.enable = true;

  fonts.fontconfig.defaultFonts = {
    monospace = [ "JetBrainsMono Nerd Font Mono" ];
  };  

  # Audio settings specific to this machine
  services.pipewire.jack.enable = true;

  # Enabling due to issues with Wayland & screen sharing
  xdg.portal.enable = true;
  
  # Enabling to build images for Raspberry Pi
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # nordvpn settings:
  services.nordvpn.enable = true;
  networking.firewall.allowedTCPPorts = [ 443 ];
  networking.firewall.allowedUDPPorts = [ 1194 ];
  networking.firewall.checkReversePath = "loose";

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
