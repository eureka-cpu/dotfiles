{ lib, config, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    optional
    ;

  cfg = config.services.gh-mdbook-server;
in
{
  options.services.gh-mdbook-server = {
    enable = mkEnableOption "gh-mdbook-server";

    remote = mkOption {
      type = types.str;
      description = "The git repository URI.";
    };

    branch = mkOption {
      type = types.str;
      default = "master";
      description = "The default branch of the git repository.";
    };

    user = mkOption {
      type = types.str;
      description = "The user the service will be ran by.";
    };

    group = mkOption {
      type = types.str;
      default = "users";
      description = "The group the user belongs to.";
    };

    local = mkOption {
      type = types.str;
      description = "The directory of the local git repository.";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "The host address the server will bind to.";
    };

    port = mkOption {
      type = types.port;
      default = 3000;
      description = "The port the server will bind to.";
    };

    update = mkOption {
      type = types.bool;
      default = false;
      description = "Enable automatic git fetch and pull for the repository.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.gh-mdbook-server = {
      description = "gh-mdbook-server";
      after = [ "network.target" ] ++ optional cfg.update "gh-mdbook-update.service";
      wants = optional cfg.update "gh-mdbook-update.service";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        WorkingDirectory = cfg.local;
        Restart = "always";

        ExecStart = ''
          ${pkgs.mdbook}/bin/mdbook serve \
            --hostname ${cfg.host} \
            --port ${toString cfg.port}
        '';
      };
    };

    systemd.services.gh-mdbook-update = mkIf cfg.update {
      description = "gh-mdbook-update";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = cfg.group;
        Environment = "PATH=${builtins.concatStringsSep ":" ["${pkgs.git}/bin" "${pkgs.openssh}/bin"]}";
        WorkingDirectory = cfg.local;

        ExecStart = pkgs.writeShellScript "gh-mdbook-update" ''
          set -euo pipefail

          git fetch origin

          if ! git diff --quiet || ! git diff --cached --quiet; then
            echo "gh-mdbook-update: local changes present, skipping update..."
            exit 0
          fi
          if [ -e .git/MERGE_HEAD ] || [ -d .git/rebase-apply ] || [ -d .git/rebase-merge ]; then
            echo "gh-mdbook-update: repository in merge/rebase state, skipping update..."
            exit 0
          fi

          echo "gh-mdbook-update: repository clean, pulling updates..."
          git pull --ff-only origin ${cfg.branch}
        '';
      };
    };

    systemd.timers.gh-mdbook-update = mkIf cfg.update {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5min";
        OnUnitActiveSec = "1d";
        Unit = "gh-mdbook-update.service";
      };
    };
  };
}
