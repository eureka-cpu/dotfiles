{
  description = "One flake to rule them all.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    x1e-nixos-config = {
      url = "github:eureka-cpu/x1e-nixos-config?ref=eureka-cpu/211";
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
    helix-themes.url = "github:CptPotato/helix-themes";
    nix-colors.url = "github:misterio77/nix-colors";
    brave-torrent.url = "github:nixos/nixpks/bfbd5014640db4509f601878a2f2a9216a0459d0";
  };

  outputs =
    { self
    , nixpkgs
    , nix-darwin
    , home-manager
    , awww
    , nix-colors
    , brave-torrent
    , ...
    }@inputs:

    let
      inherit (nixpkgs) lib;

      users = builtins.attrNames (builtins.readDir ./users);
      systemsFor = { user, type }:
        let
          path = ./users/${user}/${type}/configurations;
        in
        if builtins.pathExists path then
          builtins.attrNames (builtins.readDir path)
        else
          [ ];

      genSystem = builder: { user, hostname, type }:
        let
          host = "${self}/users/${user}/${type}/configurations/${hostname}";
        in
        builder {
          modules = lib.collect lib.isFunction (self."${type}Modules") ++ [
            (host + "/configuration.nix")
            home-manager."${type}Modules".home-manager
            {
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                users.${user} = host + "/home-manager";
                sharedModules = [ inputs.helix-themes.homeManagerModule ];
              };
            }
          ] ++ lib.optional (type == "nixos")
            {
              # TODO: Use hyprpaper and stylix so we can just remove this
              nixpkgs.overlays = [ awww.overlays.default ];
              home-manager.extraSpecialArgs = { inherit nix-colors brave-torrent; };
            };
        };

      genSystems = { builder, type }: lib.mergeAttrsList (map
        (user:
          lib.listToAttrs (map
            (hostname:
              lib.nameValuePair "${user}-${hostname}" (genSystem builder {
                inherit user hostname type;
              })
            )
            (systemsFor { inherit user type; }))
        )
        users);
    in
    {
      # All user defined home-manager modules go here
      homeManagerModules = {
        helix-themes = inputs.helix-themes.homeManagerModule;
      };

      # All user defined nixos modules go here
      nixosModules = {
        eureka.hardware-profiles = {
          apple-silicon = { config, lib, ... }: {
            imports = [ inputs.nixos-apple-silicon.nixosModules.default ];
            config.hardware.asahi.enable = lib.mkDefault false;
            config.nixpkgs.overlays = lib.optional
              config.hardware.asahi.enable
              inputs.nixos-apple-silicon.overlays.default;
          };
          qcom-x1e80100 = { config, lib, ... }: {
            imports = [ inputs.x1e-nixos-config.nixosModules.x1e ];
          };
        };
      };
      # All nixos systems per-user go here
      nixosConfigurations = genSystems {
        type = "nixos";
        builder = nixpkgs.lib.nixosSystem;
      };

      # All user defined darwin modules go here
      darwinModules = { };
      # All darwin systems per-user go here
      darwinConfigurations = genSystems {
        type = "darwin";
        builder = nix-darwin.lib.darwinSystem;
      };
    };
}
