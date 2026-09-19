{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.modules.ai.openchamber;
  loopback = cfg.host == "127.0.0.1" || cfg.host == "localhost" || cfg.host == "::1";

  # OpenChamber looks up `opencode` on PATH when it starts a managed agent.
  servicePath = lib.makeBinPath [
    pkgs.openchamber
    pkgs.pkgs-master.opencode
    pkgs.git
    pkgs.openssh
    pkgs.coreutils
  ];

  serveScript = pkgs.writeShellScript "openchamber-serve" ''
    set -euo pipefail
    pw_file=${lib.escapeShellArg cfg.uiPasswordFile}
    if [ -f "$pw_file" ]; then
      set -a
      # shellcheck disable=SC1090
      . "$pw_file"
      set +a
    fi
    if [ -z "''${OPENCHAMBER_UI_PASSWORD:-}" ] && [ ${if loopback then "0" else "1"} -eq 1 ]; then
      echo "openchamber: OPENCHAMBER_UI_PASSWORD is required when binding to ${cfg.host}" >&2
      echo "openchamber: put it in $pw_file as OPENCHAMBER_UI_PASSWORD=..." >&2
      exit 1
    fi
    exec ${lib.getExe pkgs.openchamber} serve --foreground --port ${toString cfg.port} --host ${lib.escapeShellArg cfg.host}
  '';

in
{
  options.modules.ai.openchamber = {
    service.enable = lib.mkEnableOption "OpenChamber user service (launchd on macOS, systemd --user on Linux)";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port the OpenChamber web server listens on.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = ''
        Bind address. Loopback on a laptop. 0.0.0.0 on ipad-box so the
        Tailscale interface can reach it; the public firewall stays closed.
      '';
    };

    uiPasswordFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.config/openchamber/ui-password.env";
      description = ''
        Runtime path of an env file containing OPENCHAMBER_UI_PASSWORD=....
        A string, not a Nix path, so the secret is never copied into the store.
        Created with a random value on first activation if missing.
      '';
    };
  };

  config = lib.mkMerge [
    {
      # OpenChamber is the web/PWA workspace for OpenCode. Packaged in
      # overlays/openchamber; the macOS desktop app is the Homebrew cask.
      home.packages = [ pkgs.openchamber ];
    }

    (lib.mkIf cfg.service.enable {
      # Do not run `openchamber startup enable`: it writes a unit/plist that
      # would fight these home-manager entries.
      home.activation.openchamberUiPassword = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        pw_file=${lib.escapeShellArg cfg.uiPasswordFile}
        mkdir -p "$(dirname "$pw_file")"
        if [ ! -f "$pw_file" ]; then
          umask 077
          printf 'OPENCHAMBER_UI_PASSWORD=%s\n' "$(${pkgs.openssl}/bin/openssl rand -hex 16)" > "$pw_file"
          chmod 600 "$pw_file"
        fi
        ${lib.optionalString pkgs.stdenv.isDarwin ''
          mkdir -p "${config.home.homeDirectory}/Library/Logs/OpenChamber"
        ''}
      '';

      systemd.user.services.openchamber = lib.mkIf pkgs.stdenv.isLinux {
        Unit = {
          Description = "OpenChamber web server";
          After = [ "network-online.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${serveScript}";
          Restart = "always";
          RestartSec = 5;
          WorkingDirectory = config.home.homeDirectory;
          Environment = [
            "HOME=${config.home.homeDirectory}"
            "PATH=${servicePath}"
          ];
        };
        Install.WantedBy = [ "default.target" ];
      };

      launchd.agents.openchamber = lib.mkIf pkgs.stdenv.isDarwin {
        enable = true;
        config = {
          Label = "dev.openchamber.web";
          ProgramArguments = [ "${serveScript}" ];
          EnvironmentVariables = {
            HOME = config.home.homeDirectory;
            PATH = servicePath;
            SSH_AUTH_SOCK = "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
          };
          ProcessType = "Background";
          RunAtLoad = true;
          KeepAlive = true;
          WorkingDirectory = config.home.homeDirectory;
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/OpenChamber/startup.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/OpenChamber/startup.err.log";
        };
      };
    })
  ];
}
