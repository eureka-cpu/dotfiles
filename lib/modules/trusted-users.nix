{ config, lib, ... }:
{
  options.users.users = lib.mkOption {
    # Map to the name of the user this is for
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        trustedUsers =
          let
            host = lib.types.submodule {
              options = {
                name = lib.mkOption {
                  type = lib.types.singleLineStr;
                  description = "The machine's networking.hostName";
                };
                key = lib.mkOption {
                  type = lib.types.singleLineStr;
                  description = "The ssh pubkey for this machine";
                };
              };
            };
          in
          lib.mkOption {
            type = lib.types.listOf host;
            default = [];
            description = "A list of machines owned by the user";
          };
      };
    });
    description = "Map a list of trusted hosts to a user's authorized keys";
  };

  # Get access to the name attribute and the user attrset
  config.users.users = lib.mapAttrs (_name: user: {
    openssh.authorizedKeys.keys =
      let
        # Remove the current host from the set of hosts
        hosts = lib.filter (host: host.name != config.networking.hostName) user.hosts;
      in
      lib.mkAfter (lib.unique (map (host: host.key) hosts));
  })
    config.users.users;
}
