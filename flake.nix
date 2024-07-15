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

      userLib = import ./users.nix;
      userl = userLib.userl;
      users = userLib.foldUserl userl;
      # Create an attrset of nixos system configurations for a user's systems.
      foldUserSysteml = user: hostl:
        let
          nixosSystems' = { };
        in
        builtins.foldl'
          (nixosSystems': host: nixosSystems' // {
            ${host} = nixpkgs.lib.nixosSystem {
              inherit system;
              modules = [
                users.${user}.systems.${host}.modulePath
                home-manager.nixosModules.home-manager
                {
                  home-manager = {
                    useUserPackages = true;
                    useGlobalPkgs = true;
                    extraSpecialArgs = {
                      inherit
                        helix-themes
                        nix-colors;
                      user = users.${user};
                    };
                    users.${user} = users.${user}.home-manager.modulePath;
                  };
                }
              ];
              specialArgs = {
                user = users.${user};
                host = users.${user}.systems.${host};
              };
            };
          })
          nixosSystems'
          hostl;
      # Combine all users system configurations into an attrset.
      foldSysteml = userl:
        let
          nixosSystems' = { };
        in
        builtins.foldl'
          (nixosSystems': user:
            nixosSystems' // foldUserSysteml user.name user.hostl
          )
          nixosSystems'
          userl;
    in
    {
      nixosConfigurations = foldSysteml userl;

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nil
          nixpkgs-fmt
        ];
      };

      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
