# List of users, their systems and information that is shared between them.
#
# NOTE: `foldUserl` and `foldHostl` describe the pattern that the flake expects
#        for finding the absolute paths to the nixos and home-manager modules.
#        To add your configuration files, start by adding your user information
#        below in the `users` list of attribute sets, in the format defined, then
#        reference the existing file tree under `./users` and add a directory
#        named after the attribute set you've just created, `users.<your-name>`.
{
  # Creates an attrset of users from a list of user data and information that is shared across their systems.
  foldUserl = userl:
    let
      # Creates an attrset of hosts for a user from a list of host systems.
      foldHostl = user:
        let
          hostl = user.hostl;
          hosts' = { };
        in
        builtins.foldl'
          (hosts': host:
            hosts' // {
              ${host} = {
                networking.hostName = host;
                modulePath = ./users/${user.name}/systems/${host}/configuration.nix;
                home-manager.modulePath = ./users/${user.name}/systems/${host}/home-manager;
              };
            })
          hosts'
          hostl;
      users' = { };
    in
    builtins.foldl'
      (users': user:
        users' // {
          ${user.name} = {
            name = user.name;
            github = user.github;
            description = user.description;
            homeDirectory = "/home/${user.name}";
            systems.hosts = foldHostl user;
          };
        })
      users'
      userl;

  # Each attrset in the list represents a user, their host systems and any other extraneous data
  # that may be shared across their host systems.
  userl = [
    {
      name = "eureka";
      github = {
        username = "eureka-cpu";
        profile = "github.com/eureka-cpu";
      };
      description = "Chris O'Brien";
      hostl = [
        "critter-tank"
        "dev-one"
        # "tensorbook"
        # "pop-os"
        # "yabai"
      ];
    }
    {
      name = "andrewvious";
      github = {
        username = "andrewvious";
        profile = "github.com/andrewvious";
      };
      description = "Andrew O'Brien";
      hostl = [
        "asus-rog"
        "dev-one"
      ];
    }
  ];
}
