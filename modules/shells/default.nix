{ config, pkgs, ... }:

{
  imports = [
    ./zsh.nix
    ./fzf.nix
  ];
}