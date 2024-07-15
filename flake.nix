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
      # Create an attrset of nixos system configurations for a user's host systems.
      foldUserSysteml = user: hostl:
        builtins.foldl'
          (nixosSystems': host: nixosSystems' // {
            # TODO: Get this block reduced to `users.${user}.systems.hosts.${host}.nixosSystem`
            # We want to improve readability but also not force top-level inputs on any one system.
            # If each system has its own flake then it gives more independence to that system
            # while also having the benefit of being aware of the other configurations of systems
            # belonging to that user. This way you only need to declare most things once.
            ${host} = nixpkgs.lib.nixosSystem {
              inherit system;
              modules = [
                users.${user}.systems.hosts.${host}.modulePath
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
                    users.${user} = users.${user}.systems.hosts.${host}.home-manager.modulePath;
                  };
                }
              ];
              specialArgs = {
                user = users.${user};
                host = users.${user}.systems.hosts.${host};
              };
            };
          })
          { }
          hostl;
      # Combine all users system configurations into an attrset.
      foldSysteml = userl:
        builtins.foldl'
          (nixosSystems': user:
            nixosSystems' // foldUserSysteml user.name user.hostl
          )
          { }
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
