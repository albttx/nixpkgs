{ config, pkgs, lib, home-manager, ... }:
let
  #secrets = import ../../secrets.nix;
in {
  imports = [
    ../common/darwin/defaults.nix

    ../../darwin/bootstrap.nix
  ];

  programs.nix-index.enable = true;
  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [ ];

  ids.gids.nixbld = 350; # [hack]

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig =
    "$HOME/go/src/github.com/albttx/nixpkgs/machines/github-ci/default.nix";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  system.primaryUser = "runner";
}
