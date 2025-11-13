{
  description = "one flake to rule them all";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helix-themes.url = "github:eureka-cpu/helix-themes.nix";
    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { self, nixpkgs, home-manager, ... } @inputs:
  let
    system = "aarch64-linux";
  in
  {
    overlays = {
      apple-silicon = inputs.nixos-apple-silicon.overlays.default;
    };
    nixosConfigurations = {
      jinx = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          {
            documentation.nixos.enable = false;
            nixpkgs = {
              overlays = (builtins.attrValues self.overlays);
            };
          }
          ./nixos/configuration.nix
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
