{ config, pkgs, ... }:

{
  imports = [
    ./go.nix
    ./nodejs.nix
  ];
}
