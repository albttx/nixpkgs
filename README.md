# Home-manager

Personal system configuration managed with [Nix](https://nixos.org/), [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager).

## Machines

`make switch` targets the current hostname.

### mbp-albttx

Personal MacBook Pro. nix-darwin + home-manager on `aarch64-darwin`. Config: [`machines/mbp-albttx`](machines/mbp-albttx).

### ipad-box

<p align="center">
  <img src="machines/ipad-box/banner.jpg" alt="albttx@ipad-box" width="100%">
</p>

Hetzner dedicated NixOS server (`x86_64-linux`). Rebuild on the box with `make switch` or `nixos-rebuild switch --flake .#ipad-box`. Config: [`machines/ipad-box`](machines/ipad-box).

## Installation

```sh
# install nix
curl -L https://nixos.org/nix/install | sh -s -- --daemon

# install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

```

## Usage

| Command              | Description                                |
|----------------------|--------------------------------------------|
| `make`               | Build and switch (alias for `make switch`) |
| `make switch`        | Build and switch to the current hostname   |
| `make fmt`           | Format all `.nix` files                    |
| `make clean`         | Run nix garbage collection                 |
| `make fclean`        | Deep clean (requires root)                 |

### Updating flake inputs

| Command              | Description                |
|----------------------|----------------------------|
| `make update`        | Update all flake inputs    |
| `make update.nix`    | Update nix channels only   |
| `make update.osx`    | Update nix-darwin only     |
| `make update.home`   | Update home-manager only   |
| `make update.emacs`  | Update emacs channels only |
