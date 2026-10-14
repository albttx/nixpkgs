# Traefik — single HTTP entry point for the box's services.
#
# Reachable on the tailnet only. Traefik listens on every interface, but
# unlike Docker's published ports it is an ordinary process, so the NixOS
# firewall applies: 80/443 are deliberately absent from
# networking.firewall.allowedTCPPorts, and tailscale0 is a trusted interface
# (see ../networking.nix). Adding 80/443 to allowedTCPPorts would publish all
# of this on the Hetzner WAN address — don't.
{ config, lib, ... }:

let
  domain = "box.albttx.tech";

  # Cloudflare API token for the ACME DNS-01 challenge, as
  #   CLOUDFLARE_DNS_API_TOKEN=...
  # Kept in a root-only file on the encrypted root rather than inline, because
  # anything written in a .nix file lands in the world-readable /nix/store —
  # the same reasoning as users.users.root.hashedPasswordFile in ../home.nix.
  # The token needs Zone:DNS:Edit + Zone:Zone:Read on albttx.tech.
  credentialsFile = "/etc/traefik/cloudflare.env";

  # A router per service. Each becomes <name>.${domain}.
  backends = {
    shelfmark = "http://127.0.0.1:8084";
  };
in
{
  # The token file itself is written by hand — it must not be in /nix/store —
  # but the directory holding it can be declared.
  systemd.tmpfiles.rules = [ "d ${builtins.dirOf credentialsFile} 0700 root root -" ];

  services.traefik = {
    enable = true;
    environmentFiles = [ credentialsFile ];

    staticConfigOptions = {
      entryPoints.web = {
        address = ":80";
        http.redirections.entryPoint = {
          to = "websecure";
          scheme = "https";
        };
      };

      entryPoints.websecure = {
        address = ":443";
        # Terminate TLS with one wildcard cert for the whole entry point, so
        # routers below need no TLS config of their own and adding a service
        # never triggers a new certificate order.
        http.tls = {
          certResolver = "letsencrypt";
          domains = [
            {
              main = domain;
              sans = [ "*.${domain}" ];
            }
          ];
        };
      };

      certificatesResolvers.letsencrypt.acme = {
        email = "contact@albttx.tech";
        storage = "${config.services.traefik.dataDir}/acme.json";
        # DNS-01 rather than HTTP-01: ${domain} resolves to a tailnet address,
        # so Let's Encrypt cannot reach this box to answer an HTTP challenge.
        # DNS-01 is also the only challenge type that can issue a wildcard.
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = [
            "1.1.1.1:53"
            "8.8.8.8:53"
          ];
        };
      };

      api.dashboard = true;
      log.level = "INFO";
    };

    dynamicConfigOptions = {
      http.routers = {
        traefik = {
          rule = "Host(`traefik.${domain}`)";
          service = "api@internal";
          entryPoints = [ "websecure" ];
        };
      }
      // lib.mapAttrs (name: _: {
        rule = "Host(`${name}.${domain}`)";
        service = name;
        entryPoints = [ "websecure" ];
      }) backends;

      http.services = lib.mapAttrs (_: url: {
        loadBalancer.servers = [ { inherit url; } ];
      }) backends;
    };
  };
}
