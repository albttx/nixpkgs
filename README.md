# Home-manager

Personal system configuration managed with [Nix](https://nixos.org/), [nix-darwin](https://github.com/LnL7/nix-darwin) and [home-manager](https://github.com/nix-community/home-manager).

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
