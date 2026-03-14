{
  description = "One flake to rule them all.";

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

  outputs =
    { self
    , nixpkgs
    , nix-darwin
    , home-manager
    , awww
    , helix-themes
    , nix-colors
    }:

    let
      inherit (nixpkgs) lib;
      users = builtins.attrNames (builtins.readDir ./users);
      systemsFor = { user, platform }:
        let
          path = ./users/${user}/${platform}/configurations;
        in
        if builtins.pathExists path then
          builtins.attrNames (builtins.readDir path)
        else
          [];
      mkSystem = { user, hostname, platform }:
        let
          mkSystem = if platform == "darwin" then
            nix-darwin.lib.darwinSystem
          else
            nixpkgs.lib.nixosSystem;
          host = "${self}/users/${user}/${platform}/configurations/${hostname}";
        in
        mkSystem {
          modules = [
            (host + "/configuration.nix")
            home-manager."${platform}Modules".home-manager
            {
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                users.${user} = host + "/home-manager";
                sharedModules = [ helix-themes.homeManagerModule ];
              };
            }
          ] ++ lib.optional (platform == "nixos")
            {
              # TODO: Use hyprpaper and stylix so we can just remove this
              nixpkgs.overlays = [ awww.overlays.default ];
              home-manager.extraSpecialArgs = { inherit nix-colors; };
            };
        };
      genSystems = platform: lib.mergeAttrsList (map (user:
        lib.listToAttrs (map (hostname:
          lib.nameValuePair "${user}-${hostname}" (mkSystem {
            inherit user hostname platform;
          })
        ) (systemsFor { inherit user platform; }))
      ) users);
    in
    {
      # All user defined home-manager modules go here
      homeManagerModules = {};

      # All user defined nixos modules go here
      nixosModules = {};
      # All nixos systems per-user go here
      nixosConfigurations = (genSystems "nixos");

      # All user defined darwin modules go here
      darwinModules = {};
      # All darwin systems per-user go here
      darwinConfigurations = (genSystems "darwin");
    };
}
