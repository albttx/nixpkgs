# Shelfmark — self-hosted book/audiobook search & request UI.
# Official install is the Docker image (no first-class Nix package):
#   https://github.com/calibrain/shelfmark
#   compose: https://github.com/calibrain/shelfmark/blob/main/compose/docker-compose.yml
{ ... }:

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
    # networking.firewall says. Keep the publish on loopback; Traefik is the
    # way in, at https://shelfmark.box.albttx.tech (see ./traefik.nix).
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
}
