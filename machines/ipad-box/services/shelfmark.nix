# Shelfmark — self-hosted book/audiobook search & request UI.
# Official install is the Docker image (no first-class Nix package):
#   https://github.com/calibrain/shelfmark
#   compose: https://github.com/calibrain/shelfmark/blob/main/compose/docker-compose.yml
{ config, lib, ... }:

let
  dataDir = "/var/lib/shelfmark";
  # Official compose uses PUID/PGID 1000. That is also the first regular
  # NixOS user (albttx) on this box.
  uid = "1000";
  gid = "1000";
  port = 8084;
in
{
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 ${uid} ${gid} -"
    "d ${dataDir}/config 0750 ${uid} ${gid} -"
    "d ${dataDir}/books 0750 ${uid} ${gid} -"
  ];

  virtualisation.oci-containers.containers.shelfmark = {
    image = "ghcr.io/calibrain/shelfmark:v1.3.15";
    autoStart = true;
    # Docker published ports bypass the NixOS firewall, so binding 0.0.0.0
    # would expose this on the public WAN address no matter what
    # networking.firewall says. Keep the publish on loopback; the tailnet
    # gets it through `tailscale serve` below.
    ports = [ "127.0.0.1:${toString port}:${toString port}" ];
    volumes = [
      "${dataDir}/config:/config"
      "${dataDir}/books:/books"
    ];
    environment = {
      PUID = uid;
      PGID = gid;
      TZ = "UTC";
      SEARCH_MODE = "universal";
    };
    extraOptions = [
      "--health-cmd=curl -sf http://localhost:8084/api/health || exit 1"
      "--health-interval=30s"
      "--health-timeout=30s"
      "--health-retries=3"
    ];
  };

  # Publish on the tailnet without writing this node's tailnet address down
  # anywhere: `tailscale serve` proxies <node>:${toString port} to the loopback
  # publish above, and tailscaled takes the address from the interface it
  # manages. Nothing to update if the node is ever re-registered.
  #
  #   http://ipad-box:${toString port}   (MagicDNS)  — tailnet only, not Funnel
  #
  # --tcp rather than --http: the HTTP forwarder matches on the Host header and
  # answers 404 to requests addressed to the bare 100.x address, while the TCP
  # forwarder serves both the MagicDNS name and the tailnet IP.
  #
  # Serve config is persisted in tailscaled's state, so this unit is really
  # just making that state declarative; it is idempotent on every rebuild.
  systemd.services.shelfmark-tailscale-serve =
    let
      tailscale = lib.getExe config.services.tailscale.package;
    in
    {
      description = "Expose Shelfmark on the tailnet";
      after = [
        "tailscaled.service"
        "docker-shelfmark.service"
      ];
      wants = [ "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${tailscale} serve --bg --yes --tcp ${toString port} tcp://127.0.0.1:${toString port}";
        ExecStop = "${tailscale} serve --tcp=${toString port} off";
        # tailscaled is up before it is logged in and addressable; retry rather
        # than fail the boot if serve runs a moment too early.
        Restart = "on-failure";
        RestartSec = "5s";
      };
      startLimitIntervalSec = 300;
      startLimitBurst = 20;
    };
}
