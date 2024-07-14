{
  description = "one flake to rule them all";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helix-themes.url = "github:eureka-cpu/helix-themes.nix";
    nix-colors.url = "github:misterio77/nix-colors";
  };

  # TODO: Use flake-utils
  outputs = { nixpkgs, home-manager, helix-themes, nix-colors, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      users = import ./users.nix;
    in
    {
      # TODO: Map user/host to nixosSystem
      nixosConfigurations = {
        critter-tank = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            users.eureka.systems.critter-tank.modulePath
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                extraSpecialArgs = {
                  inherit
                    helix-themes
                    nix-colors;
                  user = users.eureka;
                };
                users.eureka = users.eureka.home-manager.modulePath;
              };
            }
          ];
          specialArgs = { inherit users; };
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nil
          nixpkgs-fmt
        ];
      };

      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
