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
