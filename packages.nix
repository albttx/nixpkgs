{ config, pkgs, ... }:

{
  home.packages =  with pkgs; [
    emacs
    ripgrep
    tree
    jq
    entr

    just

    keybase
    gnupg

    docker

    nixfmt
  ];
}
