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
