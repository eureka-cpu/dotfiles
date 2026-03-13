# Takes all of the user's configurations and maps the ssh keys of the machines
{ config, lib, self, ... }:
{
  options.users.users = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options.openssh.hostKeys = lib.mkOption {
        type = lib.types.listOf lib.types.singleLineStr;
        default = [];
        description = ''
          The host's SSH public keys, used to authorize this machine to connect
          to the user's other systems. Generate with services.openssh.hostKeys
          and copy the public key here.
        '';
      };
    });
  };

  # Get access to the name attribute and the user attrset
  config.users.users = lib.mapAttrs (user: cfg: {
    openssh.authorizedKeys.keys =
      let
        allHosts =
          (self.${user}.nixosConfigurations or {})
          // (self.${user}.darwinConfigurations or {});

        # Remove the current host from the set of hosts
        hosts = lib.filterAttrs (_: host:
          host.config.networking.hostName != config.networking.hostName)
          allHosts;

        getKeysFrom = _: host:
          host.config.users.users.${user}.openssh.hostKeys or [];

        keys = lib.unique (lib.concatLists (lib.mapAttrsToList getKeysFrom hosts));
      in
      lib.mkAfter keys;
  })
    config.users.users;
}
