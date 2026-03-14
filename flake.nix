{
  description = ''
    Dotfiles follow a very common pattern. There are users, users own systems,
    systems have modules. Sometimes systems have more than one user, sometimes
    users have more than one system. This is basically a matrix of users and
    systems, and their modules.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    awww = {
      url = "git+https://codeberg.org/LGFae/awww";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helix-themes.url = "github:eureka-cpu/helix-themes?ref=eureka-cpu/0";
    nix-colors.url = "github:misterio77/nix-colors";
  };

  # There must be some way of defining a flake which shares modules between
  # users such that users can refer to other users for permissions, and
  # allows users to rebuild-switch and also see the flake outputs per-user.
  #
  # The goal is to make it so that one can do the following:
  #
  # outputs.<user>.homeModules (refer to home modules)
  # outputs.<user>.nixosModules (module introspection)
  # outputs.<user>.nixosConfigurations.<system>.<hostname> (nixos-rebuild switch --flake .#<user>.nixosConfigurations.<system>.<hostname>)
  # outputs.<user>.darwinModules (module introspection)
  # outputs.<user>.darwinConfigurations.<system>.<hostname> (darwin-rebuild switch --flake .#<user>.darwinConfigurations.<system>.<hostname>)
  #
  # For nixosConfigurations and darwinConfigurations, it would be great to
  # have a mapping such that it produces a configuration for the system attribute.
  # This means that `nixosConfigurations.aarch64-linux.<hostname>` would produce
  # a `nixosSystem` where `system = "aarch64-linux"`.
  #
  # In addition, each system should be able to reference other user modules
  # and user information in order to set `users.users.<user>` and groups.
  outputs =
    { self
    , nixpkgs
    , nix-darwin
    , home-manager
    , awww
    , helix-themes
    , nix-colors
    }:
    {
      # All user defined home-manager modules go here
      homeManagerModules = {};

      # All user defined nixos modules go here
      nixosModules = {};
      # All nixos systems per-user go here
      nixosConfigurations = {
        # TODO: create the generator code which uses the file structure to automatically
        # find the nixos configurations and home-manager configurations for the system.
        critter-tank = nixpkgs.lib.nixosSystem {
          modules = [
            ./users/eureka/systems/critter-tank/configuration.nix
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [
                awww.overlays.default
              ];
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                users.eureka = ./users/eureka/systems/critter-tank/home-manager;
                sharedModules = [
                  helix-themes.homeManagerModule
                ];
                extraSpecialArgs = {
                  inherit nix-colors;
                };
              };
            }
          ];
        };
      };

      # All user defined darwin modules go here
      darwinModules = {};
      # All darwin systems per-user go here
      darwinConfigurations = {
        yabai = nix-darwin.lib.darwinSystem {
          modules = [
            ./users/eureka/systems/yabai/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                users.eureka = ./users/eureka/systems/yabai/home-manager;
              };
            }
          ];
        };
      };
    };
}
