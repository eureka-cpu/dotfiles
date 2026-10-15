# OpenClaw gateway for the `openclaw` user (nix-openclaw Home Manager module,
# systemd user service kept alive by linger).
#
# The agent can run shell commands, so the OS user is the security boundary:
# no wheel, no password, no SSH keys, its own home. Admin goes through root.
#
# Secrets are placed by hand over SSH and never enter git or the Nix store:
#   /var/lib/openclaw-secrets/anthropic-api-key  Anthropic API key
#   /var/lib/openclaw-secrets/gateway-token      random gateway auth token
#   /var/lib/openclaw-secrets/github-token       GitHub token
#
# Workspace bootstrap files (AGENTS.md, SOUL.md, TOOLS.md, IDENTITY.md,
# USER.md) are host-local too, kept out of this public repo. Root maintains
# them in /var/lib/openclaw-workspace; every gateway start copies them over
# the workspace, reverting any edits the agent made.
{ ... }:
let
  secretsDir = "/var/lib/openclaw-secrets";
  workspaceSrc = "/var/lib/openclaw-workspace";
  bootstrapNames = [ "AGENTS.md" "SOUL.md" "TOOLS.md" "IDENTITY.md" "USER.md" ];
  uid = 1001;
in
{
  users.groups.openclaw = { };
  users.users.openclaw = {
    inherit uid;
    isNormalUser = true;
    description = "OpenClaw gateway";
    group = "openclaw";
    home = "/var/lib/openclaw";
    createHome = true;
    # Runs the user service at boot without anyone logging in.
    linger = true;
  };

  # Lingering starts the user manager in parallel with Home Manager
  # activation; if it wins, it never sees the gateway unit and HM skips its
  # reload ("User systemd daemon not running"). Make it wait for activation.
  systemd.services."user@${toString uid}" = {
    after = [ "home-manager-openclaw.service" ];
    wants = [ "home-manager-openclaw.service" ];
  };

  systemd.tmpfiles.rules = [
    # Root drops secret files here; boot hands them to the gateway user.
    "d ${secretsDir} 0700 openclaw openclaw - -"
    "Z ${secretsDir} - openclaw openclaw - -"
    # Readable by the gateway, writable only by root.
    "d ${workspaceSrc} 0750 root openclaw - -"
  ];

  home-manager.users.openclaw = { config, pkgs, ... }: {
    home.stateVersion = "26.05";

    programs.openclaw = {
      enable = true;

      # Default toolchain minus media, Python, and Google/Sonos/camera CLIs.
      toolNames = [ "git" "curl" "jq" "ripgrep" ];
      bundledPlugins.goplaces.enable = false;
      runtimePackages = [ pkgs.gh ];

      # File paths are read by the gateway wrapper at startup.
      environment = {
        ANTHROPIC_API_KEY = "${secretsDir}/anthropic-api-key";
        OPENCLAW_GATEWAY_TOKEN = "${secretsDir}/gateway-token";
        GH_TOKEN = "${secretsDir}/github-token";
      };

      config = {
        gateway = {
          mode = "local";
          bind = "loopback";
          auth = {
            mode = "token";
            token = {
              source = "env";
              provider = "default";
              id = "OPENCLAW_GATEWAY_TOKEN";
            };
          };
        };
        agents.defaults = {
          # Bootstrap files come from ${workspaceSrc}, never bundled templates.
          skipBootstrap = true;
          model.primary = "anthropic/claude-sonnet-5-5";
          # No channel to report to yet; enable once Signal is paired.
          heartbeat.every = "0m";
        };
        # Scheduled memory sweeps call the model and ingest unmasked chat
        # transcripts; keep memory to what the agent writes explicitly.
        plugins.entries.memory-core.config.dreaming.enabled = false;
      };
    };

    systemd.user.services.openclaw-gateway = {
      # Upstream ships no [Install]; without it linger never starts the gateway.
      Install.WantedBy = [ "default.target" ];
      Service = {
        # Blocks setuid escalation (sudo etc.) from anything the agent runs.
        NoNewPrivileges = true;
        # Fails the start if any bootstrap file is missing, rather than
        # running the agent without its rules.
        ExecStartPre = toString (pkgs.writeShellScript "openclaw-workspace-sync" ''
          set -eu
          dst=${config.programs.openclaw.workspaceDir}
          ${pkgs.coreutils}/bin/mkdir -p "$dst"
          for f in ${toString bootstrapNames}; do
            ${pkgs.coreutils}/bin/rm -f "$dst/$f"
            ${pkgs.coreutils}/bin/install -m 0444 "${workspaceSrc}/$f" "$dst/$f"
          done
        '');
      };
    };
  };
}
