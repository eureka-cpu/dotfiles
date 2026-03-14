{ config, pkgs, lib, ... }:
let
  intel_bus = "PCI:0:2:0";
  nvidia_bus = "PCI:1:0:0";
  nvidia_driver = config.boot.kernelPackages.nvidiaPackages.stable;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../../nixos/configuration.nix
    ../../../nixos/laptop-configuration.nix
  ];

  networking.hostName = "tensorbook";

  # Pinned Kernel Version
  boot.kernelPackages = pkgs.linuxPackages_zen;
  
  # Topology config for routing audio/microphone on Razer laptops
  boot.extraModprobeConfig = ''
    options snd-sof-pci tplg_filename=sof-hda-generic-2ch-pdm1.tplg
  '';
  users.users.eureka.extraGroups = [ "openrazer" ];
  hardware.openrazer.enable = true;
  environment = {
    systemPackages = with pkgs; [
      openrazer-daemon
      polychromatic
    ];
  };

  # For some reason this still tries to build from source and my user session crashes.
  # 
  xdg.portal.extraPortals = lib.mkForce (with pkgs; [
    xdg-desktop-portal-cosmic
  ]);
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  # Nvidia/Intel GPU Settings
  nixpkgs.config.nvidia.acceptLicense = true;
  boot = {
    initrd.kernelModules = [ "nvidia" ];
    blacklistedKernelModules = [ "nouveau" ];
  };
  hardware.graphics = {
    enable = true; # Must be enabled
    enable32Bit = true;
  };
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    config = ''
      Section "Device"
          Identifier "Intel Graphics"
          Driver     "intel"
          Option     "TearFree"        "true"
          Option     "AccelMethod"     "sna"
          # Option     "SwapbuffersWait" "true"
          BusID      "PCI:0:2:0"
      EndSection

      Section "Device"
          Identifier "nvidia"
          Driver     "nvidia"
          BusID      "PCI:1:0:0"
          Option     "AllowEmptyInitialConfiguration"
      EndSection
    '';
    screenSection = ''
      Option         "metamodes" "nvidia-auto-select +0+0 {ForceCompositionPipeline=On}"
      Option         "AllowIndirectGLXProtocol" "off"
      Option         "TripleBuffer" "on"
    '';
  };
  hardware.nvidia = {
    # Modesetting is needed for most Wayland compositors
    modesetting.enable = true;
    # Use the open source version of the kernel module
    # Only available on driver 515.43.04+
    open = false;
    # Enable the nvidia settings menu
    nvidiaSettings = true;
    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = nvidia_driver;
    # Optimus PRIME: Bus ID Values (Mandatory for laptop dGPUs)
    prime = {
      sync.enable = true;
      intelBusId = intel_bus;
      nvidiaBusId = nvidia_bus;
    };
  };
  specialisation = {
    blacklist-nvidia.configuration = {
      system.nixos.tags = [ "blacklist-nvidia" ];
      boot = {
        extraModprobeConfig = ''
          blacklist nouveau
          options nouveau modeset=0
        '';
        blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];
      };
      services.udev.extraRules = ''
        # Remove NVIDIA USB xHCI Host Controller devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
        # Remove NVIDIA USB Type-C UCSI devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
        # Remove NVIDIA Audio devices, if present
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
        # Remove NVIDIA VGA/3D controller devices
        ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
      '';
    };
  };

  system.stateVersion = "23.05";
}
