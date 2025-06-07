{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-apple-silicon.nixosModules.default
  ];

  boot.kernelParams = [
    "apple_dcp.unstable_edid=1" "apple_dcp.show_notch=1"
  ];
  boot.extraModprobeConfig = ''
    options hid_apple iso_layout=0
  '';
  hardware.asahi = {
    withRust = true;
    extractPeripheralFirmware = true;
    peripheralFirmwareDirectory = ./firmware;
    setupAsahiSound = true;
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
  };
  
  boot.binfmt.emulatedSystems = [
    "x86_64-linux"
    "i686-linux"
    "i386-linux"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  # Enable networking
  networking.hostName = "jinx"; # Define your hostname.
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };
  networking.wireless = {
    enable = false;
    iwd.enable = true;
  };

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

  hardware.graphics.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
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

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
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
  services.displayManager.autoLogin = {
    enable = false;
    user = "eureka";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Experimental nix features
  nix = {
    settings = {
      trusted-users = [ "root" "eureka" ];
      experimental-features = [ "nix-command" "flakes" ];
      extra-substituters = [ "https://cloud-scythe-labs.cachix.org" ];
      extra-trusted-public-keys = [
        "cloud-scythe-labs.cachix.org-1:I+IM+x2gGlmNjUMZOsyHJpxIzmAi7XhZNmTVijGjsLw="
      ];
    };
  };

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1"; # tells electron apps to use wayland
    };
  };

  fonts = {
    packages = with pkgs.nerd-fonts; [
      jetbrains-mono
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  nix.package = pkgs.nixVersions.latest;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
