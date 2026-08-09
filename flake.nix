{
  description = "One flake to rule them all.";

  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

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
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    x1e-nixos-config = {
      url = "github:kuruczgy/x1e-nixos-config";
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
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helix-themes.url = "github:CptPotato/helix-themes";
    brave-torrent.url = "github:NixOS/nixpkgs?rev=bfbd5014640db4509f601878a2f2a9216a0459d0";
    llm-agents.url = "github:numtide/llm-agents.nix";
    zerostack = {
      url = "github:gi-dellav/zerostack?ref=v1.7.2";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , nix-darwin
    , nixos-wsl
    , home-manager
    , awww
    , stylix
    , brave-torrent
    , zerostack
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
                sharedModules = builtins.attrValues self.homeManagerModules;
              };
              nixpkgs.overlays = [
                (import "${inputs.zerostack}/nix/overlay")
                (final: _prev: {
                  llm-agents = inputs.llm-agents.packages.${final.system};
                })
                # Bump kitty-themes so newer upstreamed themes (e.g. ferra) are
                # available to programs.kitty.themeFile, which hardcodes
                # pkgs.kitty-themes in the home-manager module.
                (_final: prev: {
                  kitty-themes = prev.kitty-themes.overrideAttrs (old: {
                    version = "0-unstable-2026-07-10";
                    src = prev.fetchFromGitHub {
                      owner = "kovidgoyal";
                      repo = "kitty-themes";
                      rev = "e144651f75891cf4795ef1e7c24bb3e27c47aa06";
                      hash = "sha256-cl79/m3tGZzGXBuwcIIBxsewrcgaFK0R0VRlRiiw5yk=";
                    };
                  });
                })
              ];
            }
          ] ++ lib.optional (type == "nixos")
            {
              # TODO: Use hyprpaper and stylix so we can just remove this
              nixpkgs.overlays = [
                awww.overlays.default
              ];
              home-manager.extraSpecialArgs = { inherit brave-torrent; };
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
        inherit (stylix.homeModules) stylix;
        helix-themes = inputs.helix-themes.homeManagerModule;
      };

      # All user defined nixos modules go here
      nixosModules = {
        wsl = { ... }: { imports = [ inputs.nixos-wsl.nixosModules.default ]; };
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
