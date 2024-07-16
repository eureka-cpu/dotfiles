{ pkgs, user, host, ... }:
{
  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = host.networking.hostName;
    networkmanager.enable = true;
  };

  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModulePackages = [ pkgs.linuxPackages.v4l2loopback ];

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
    };

    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Enable GPU.
  hardware.graphics.enable = true;

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
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user.name} = {
    isNormalUser = true;
    description = user.description;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
  virtualisation.docker.enable = true;

  # Enable automatic login for the user.
  services.displayManager.autoLogin = {
    enable = false;
    user = user.name;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Experimental nix features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1"; # fixes disappearing cursor
    NIXOS_OZONE_WL = "1"; # tells electron apps to use wayland
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "JetBrainsMono"
        "FiraCode"
        "GeistMono"
        "Hasklig"
        "Iosevka"
        "Lilex"
        "Monoid"
        "VictorMono"
        "ZedMono"
      ];
    })
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
