{
  description = "one flake to rule them all";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = { url = "github:musnix/musnix"; };
    helix-themes.url = "github:eureka-cpu/helix-themes.nix";
    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs =
    { nixpkgs
    , flake-utils
    , home-manager
    , musnix
    , helix-themes
    , nix-colors
    , ...
    }:
    let
      # TODO: Related to the comment below, the system will be whatever system
      # is passed to the function that creates the configuration.
      # It doesn't belong here and should be removed.
      system = flake-utils.lib.system.x86_64-linux;

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
                musnix.nixosModules.musnix
              ];
              specialArgs = {
                inherit musnix;
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
    { nixosConfigurations = foldSysteml userl; } //
    # Configurations rely on the system that is set in hardware-configuration.nix
    # so there's no need to include `system`, except for when developing the parent
    # flake.nix itself, or working on one system configuration from another.
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nil
            nixpkgs-fmt
          ];
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
