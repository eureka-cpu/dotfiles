{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../../nixos/configuration.nix
    ../../../nixos/nordvpn.nix
  ];

  networking.hostName = "asus-rog";

  # Workaround for GNOME autologin
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  services.displayManager.gdm.enable = true;

  # Hyprland
  programs.hyprland = {
    enable = true;
    package = with pkgs; builtins.trace "Built against Hyprland v${hyprland.version}" hyprland;
  };

  # Disable Webcam microphone 
  services.pipewire.wireplumber.extraConfig."51-disable-webcam-mic" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "device.name" = "alsa_card.usb-EMEET_HD_Webcam_eMeet_C960_A240229000417429-02"; }
        ];
        actions.update-props."device.disabled" = true;
      }
    ];
  };

  # Enabling to build images for Raspberry Pi
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Nvidia settings
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # Modesetting is needed for most Wayland compositors
    modesetting.enable = true;
    # Use the open source version of the kernel module
    # Only available on driver 515.43.04+
    open = false;
    # Enable the nvidia settings menu
    nvidiaSettings = true;
    # Save VRAM on suspend, preventing black screen or corruption on resume
    powerManagement.enable = true;
    # Optionally, you may need to select the appropriate driver version for your specific GPU
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  # GPU overclocking software
  services.lact.enable = true;

  # nordvpn settings:
  services.nordvpn.enable = true;
  networking.firewall.allowedTCPPorts = [ 443 ];
  networking.firewall.allowedUDPPorts = [ 1194 ];
  networking.firewall.checkReversePath = "loose";

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    # xbox controller
    input = {
      General = {
        UserspaceHID = true;
      };
    };
  };
  services.blueman.enable = true;

  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  # Proton runs on 32-bit Windows code paths
  hardware.graphics.enable32Bit = true;
  programs.gamemode.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
