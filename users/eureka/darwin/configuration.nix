{ pkgs, lib, ... }:
{
  users.users.eureka = {
    description = "Chris O'Brien";
    home = "/Users/eureka";
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  fonts.packages = with pkgs.nerd-fonts; [
    jetbrains-mono
  ];

  system = {
    primaryUser = "eureka";

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 4;
    defaults.NSGlobalDomain.NSWindowShouldDragOnGesture = true;
  };

  nix = {
    settings = {
      # Necessary for using flakes on this system.
      experimental-features = "nix-command flakes";
      # Extra artifact caches
      extra-substituters = [ "https://cloud-scythe-labs.cachix.org" ];
      extra-trusted-public-keys = [
        "cloud-scythe-labs.cachix.org-1:I+IM+x2gGlmNjUMZOsyHJpxIzmAi7XhZNmTVijGjsLw="
      ];
    };
    # Use the path to `nixpkgs` in `inputs` as $NIX_PATH
    nixPath = lib.mkForce [ "nixpkgs=${pkgs.path}" ];
    package = pkgs.nixVersions.latest;
  };
}

