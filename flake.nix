{
  description = "one flake to rule them all";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic?ref=pull/863/head";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helix-themes.url = "github:eureka-cpu/helix-themes.nix";
    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { nixpkgs, home-manager, nixos-cosmic, ... }@inputs:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations = {
      tensorbook = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./nixos/configuration.nix
          nixos-cosmic.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              extraSpecialArgs = { inherit inputs; };
              users.eureka = ./home-manager/home.nix;
            };
          }
        ];
      };
    };
  };
}
