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

  outputs = { nixpkgs, home-manager, helix-themes, nix-colors, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      # Useful for maintaining user data across home-manager modules
      # and configuration.nix
      # TODO: map user modules based on name.
      users = {
        eureka =
          let
            name = "eureka";
          in
          {
            inherit name;
            homeDirectory = "/home/${name}";
            home-manager.modulePath = ./home-manager/home.nix;
          };
      };
    in
    {
      nixosConfigurations = {
        critter-tank = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./nixos/configuration.nix
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
