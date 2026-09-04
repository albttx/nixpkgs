<p align="center">
  <img src="banner.jpg" alt="albttx@ipad-box" width="100%">
</p>

# ipad-box

Hetzner dedicated NixOS box (`x86_64-linux`). Flake output: `nixosConfigurations.ipad-box`.

```sh
# on the machine
make switch
# or
nixos-rebuild switch --flake .#ipad-box
```

User config can be applied without a full system rebuild:

```sh
make switch.home-manager
```

## Services

Container services live under [`services/`](services/). The engine is Docker
(not Podman) and it is also the `oci-containers` backend, so declarative
containers added later inherit it. `albttx` is in the `docker` group, so
`docker` / `docker compose` work without sudo.

### Shelfmark

Official image `ghcr.io/calibrain/shelfmark` on loopback `:8084`. Data: `/var/lib/shelfmark/{config,books}`.

Reachable over Tailscale only. Docker's published port stays on loopback,
because published ports bypass the NixOS firewall and `0.0.0.0` would mean the
public WAN address; `tailscale serve` fronts it on the tailnet. From any node
on the tailnet:

```
http://ipad-box:8084
```

Serve, not Funnel — it is not on the public internet, and there is no path to
it from outside the tailnet. Enable authentication in Settings before sharing
the node further.

Systemd units: `docker-shelfmark` and `shelfmark-tailscale-serve`
(`tailscale serve status` shows the proxy). Bump the tag in
`services/shelfmark.nix` to update.
