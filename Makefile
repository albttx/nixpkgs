# Home-manager

This is the home of all my configuration

## Installation

### On thinkpad

```sh
# install nix
curl -L https://nixos.org/nix/install | sh -s -- --daemon

# install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

# setup config
home-manager switch --flake .#thinkpad
```

### On my surface

```sh
# install nix
curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

# install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

# setup config
home-manager switch --flake .#surface
```

