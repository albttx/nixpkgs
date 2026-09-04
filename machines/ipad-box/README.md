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

```sh
# after `make switch`, from a laptop
ssh -L 8084:127.0.0.1:8084 albttx@ipad-box
# then open http://localhost:8084
# enable authentication in Settings before exposing it further
```

Systemd unit: `docker-shelfmark`. Bump the tag in `services/shelfmark.nix` to update.
