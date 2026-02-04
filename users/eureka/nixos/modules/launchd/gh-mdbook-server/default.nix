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
    launchd.daemons.gh-mdbook-server = {
      serviceConfig = {
        Label = "gh-mdbook-server";
  
        WorkingDirectory = cfg.local;
  
        ProgramArguments = [
          "${pkgs.mdbook}/bin/mdbook"
          "serve"
          "--hostname"
          cfg.host
          "--port"
          (toString cfg.port)
        ];
  
        KeepAlive = true;
        RunAtLoad = true;
  
        StandardOutPath = "/var/log/gh-mdbook-server.log";
        StandardErrorPath = "/var/log/gh-mdbook-server.err";
      };
    };
  
    launchd.daemons.gh-mdbook-update = mkIf cfg.update {
      serviceConfig = {
        Label = "gh-mdbook-update";
  
        UserName = cfg.user;
        GroupName = cfg.group;
  
        WorkingDirectory = cfg.local;
  
        EnvironmentVariables = {
          PATH = builtins.concatStringsSep ":" [
            "${pkgs.git}/bin"
            "${pkgs.openssh}/bin"
          ];
        };
  
        ProgramArguments = [
          "${pkgs.writeShellScript "gh-mdbook-update" ''
            set -euo pipefail
  
            git fetch origin
  
            if ! git diff --quiet || ! git diff --cached --quiet; then
              echo "gh-mdbook-update: local changes present, skipping update..."
              exit 0
            fi
  
            if [ -e .git/MERGE_HEAD ] \
               || [ -d .git/rebase-apply ] \
               || [ -d .git/rebase-merge ]; then
              echo "gh-mdbook-update: repository in merge/rebase state, skipping update..."
              exit 0
            fi
  
            echo "gh-mdbook-update: repository clean, pulling updates..."
            git pull --ff-only origin ${cfg.branch}
          ''}"
        ];
  
        RunAtLoad = true;
        StartInterval = let daily = 86400; in daily;
  
        StandardOutPath = "/var/log/gh-mdbook-update.log";
        StandardErrorPath = "/var/log/gh-mdbook-update.err";
      };
    };
  };
}
