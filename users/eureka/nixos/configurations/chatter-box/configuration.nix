# Dedicated OpenClaw gateway.
#
# Intentionally does NOT import ../../../nixos/configuration.nix; this box
# carries only what the gateway needs plus a minimal sway session for local
# console use.
#
# Never rebuilds itself. Build on another host and push the closure:
#   nixos-rebuild boot --flake .#eureka-chatter-box \
#     --target-host root@chatter-box
{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./openclaw.nix
  ];

  networking.hostName = "chatter-box";

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-f70cbbcd-1a9e-4413-bb06-a60a96143430".device =
    "/dev/disk/by-uuid/f70cbbcd-1a9e-4413-bb06-a60a96143430";

  # Early KMS: without the GPU driver in the initrd the firmware framebuffer
  # never reaches the display, so the LUKS prompt is invisible.
  boot.initrd.kernelModules = [ "i915" ];

  # Wired networking only.
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  # Administered from other hosts as root with key-only SSH.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
  users.users.root.openssh.authorizedKeys.keys = [
    # dev-one
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQ66bGgeELzU/wZjpYxSlKIgMoROQxPx76vGdpS3lwc"
  ];

  services.tailscale.enable = true;

  # Local console session.
  users.users.eureka = {
    isNormalUser = true;
    description = "Chris O'Brien";
    extraGroups = [ "networkmanager" "wheel" ];
  };
  programs.sway.enable = true;
  services.greetd = {
    enable = true;
    settings.default_session.command =
      "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd sway";
  };

  # Pulled in by default with any graphical session (~740 MiB of voices).
  services.speechd.enable = false;

  # Closures are built elsewhere and copied in; nothing on this host should
  # be able to rebuild it.
  system.disableInstallerTools = true;
  nix.channel.enable = false;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "26.05";
}
