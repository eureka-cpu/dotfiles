{ config, pkgs, lib, ... }:
{
  networking.hostName = "asus-wsl";
  nixpkgs.hostPlatform = "x86_64-linux";

  wsl.enable = true;
  wsl.defaultUser = "andrewvious";

  environment.systemPackages = with pkgs; [ git ];

  programs.zsh.enable = true;
  users.users.andrewvious.shell = pkgs.zsh;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Experimental nix features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.settings = {
    extra-substituters = [
      "https://cloud-scythe-labs.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cloud-scythe-labs.cachix.org-1:I+IM+x2gGlmNjUMZOsyHJpxIzmAi7XhZNmTVijGjsLw="
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
