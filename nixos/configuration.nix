{ config, pkgs, lib, ... }:

let
  intel_bus = "PCI:0:2:0";
  nvidia_bus = "PCI:1:0:0";
  nvidia_driver = (config.boot.kernelPackages.nvidiaPackages.beta.overrideAttrs {
    src = pkgs.fetchurl {
      url = "https://us.download.nvidia.com/XFree86/Linux-x86_64/550.40.07/NVIDIA-Linux-x86_64-550.40.07.run";
      sha256 = "sha256-KYk2xye37v7ZW7h+uNJM/u8fNf7KyGTZjiaU03dJpK0=";
    };
  });
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Pinned Kernel Version
  boot.kernelPackages = pkgs.linuxPackages_zen;
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Topology config for routing audio/microphone on Razer laptops
  boot.extraModprobeConfig = ''
    options snd-sof-pci tplg_filename=sof-hda-generic-2ch-pdm1.tplg
  '';

  # video capture from external device
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModulePackages = [ pkgs.linuxPackages_zen.v4l2loopback ];

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "tensorbook"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Display & Desktop Settings
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
    };
    displayManager.gdm.enable = true;
  };
  programs.hyprland.enable = true;

  # Nvidia/Intel GPU Settings
  boot = {
    # kernelParams = [ "acpi_rev_override" "mem_sleep_default=deep" "intel_iommu=igfx_off" "nvidia-drm.modeset=1" ];
    initrd.kernelModules = [ "nvidia" ];       # Probably redundant
    blacklistedKernelModules = [ "nouveau" ];  #
  };
  hardware.opengl = {
    enable = true; # Must be enabled
    driSupport = true;
    driSupport32Bit = true;
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
    prime-offload.configuration = {
      system.nixos.tags = [ "prime-offload" ];
      hardware.nvidia = {
        prime = {
          offload = {
            enable = lib.mkForce true;
            enableOffloadCmd = lib.mkForce true;
          };
          sync.enable = lib.mkForce false;
          intelBusId = intel_bus;
          nvidiaBusId = nvidia_bus;
        };
      };
    };
    prime-reverse-sync.configuration = {
      system.nixos.tags = [ "prime-reverse-sync" ];
      hardware.nvidia = {
        prime = {
          reverseSync.enable = lib.mkForce true;
          sync.enable = lib.mkForce false;
          intelBusId = intel_bus;
          nvidiaBusId = nvidia_bus;
        };
      };
    };
    blacklist-intel.configuration = {
      system.nixos.tags = [ "blacklist-intel" ];
      boot.kernelParams = [ "module_blacklist=i915" ];
    };
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.auto-cpufreq.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.eureka = {
    isNormalUser = true;
    description = "Chris O'Brien";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
  
  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = false;
  services.xserver.displayManager.autoLogin.user = "eureka";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Experimental nix features
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      extra-substituters = [ "https://fuellabs.cachix.org" ];
      extra-trusted-public-keys = [
        "fuellabs.cachix.org-1:3gOmll82VDbT7EggylzOVJ6dr0jgPVU/KMN6+Kf8qx8="
      ];
    };
  };

  environment = {
    sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1"; # fixes disappearing cursor
      NIXOS_OZONE_WL = "1"; # tells electron apps to use wayland
    };
  };

  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  nix.package = pkgs.nixVersions.nix_2_22;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.autoUpgrade.flake = "github:eureka-cpu/dotfiles/tree/tensorbook";
}
