{
  description = "one flake to rule them all";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations = {
      dev-one = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./nixos/configuration.nix
        ];
      };
    };
  };
}
