{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
  };

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # video capture from external device
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModulePackages = [ pkgs.linuxPackages.v4l2loopback ];

  networking.hostName = "dev-one"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" "radeon" ];
  boot.initrd.kernelModules = [ "amdgpu" "radeon" ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
  };
  
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

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

  # Enabling due to issues with Wayland & screen sharing
  xdg = {
    portal = {
      enable = true;
    };
  };

  services.auto-cpufreq.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.eureka = {
    isNormalUser = true;
    description = "Chris O'Brien";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # zsh & oh-my-zsh configurations
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    shellAliases = {
      # Use the Sway Developer Fuel Flake
      swaydev = "nix develop github:fuellabs/fuel.nix#sway-dev -c zsh";
      # Adds `.cargo/bin` to PATH ENV VAR
      pcargo = "PATH=$PATH:/home/chrisobrien/.cargo/bin";
    };
  };
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [ "git" ];
    theme = "dst";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Experimental features
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      extra-substituters = ["https://fuellabs.cachix.org"];
      extra-trusted-public-keys = [
        "fuellabs.cachix.org-1:3gOmll82VDbT7EggylzOVJ6dr0jgPVU/KMN6+Kf8qx8="
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      brave
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          bbenoist.nix
          matklad.rust-analyzer
          vadimcn.vscode-lldb
          pkief.material-product-icons
          tamasfe.even-better-toml
          esbenp.prettier-vscode
          ms-vsliveshare.vsliveshare
          vscodevim.vim
          catppuccin.catppuccin-vsc
          jdinhlife.gruvbox
          piousdeer.adwaita-theme
          zhuangtongfa.material-theme
          arcticicestudio.nord-visual-studio-code
          file-icons.file-icons
          eamodio.gitlens
        ];
      })
      gnomeExtensions.color-picker
      gnomeExtensions.pop-shell
      gnome.gnome-tweaks
      helix
      git
      zsh
      oh-my-zsh
      tdesktop
      pipes-rs
      tlp
      auto-cpufreq
      discord
      cups
      brlaser
      alacritty
      kitty
      colloid-icon-theme
      nordic
      marwaita-manjaro
      papirus-maia-icon-theme
      neofetch
      xdg-desktop-portal
      xdg-desktop-portal-gnome
      obs-studio
      blender
      steam
      gphoto2
      # linuxKernel.packages.linux_5_15.v4l2loopback
      v4l-utils
      ffmpeg
      libreoffice
      wl-clipboard
      kitty-themes
    ];

    gnome.excludePackages = with pkgs; [
      gnome.cheese
      gnome.gnome-music
      gnome-tour
      epiphany
      gnome.geary
      gnome.gedit
      gnome-text-editor
      gnome.gnome-contacts
      gnome.yelp
    ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  fonts = {
    packages = with pkgs; [
      fira
      fira-code
      jetbrains-mono
      powerline-fonts
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system = {
    autoUpgrade.enable = true;
    autoUpgrade.allowReboot = true;
  };
}
