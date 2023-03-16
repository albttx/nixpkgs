{ config, pkgs, ... }:

{
  home.packages =  with pkgs; [
    emacs
    ripgrep
    tree
    jq
    entr

    grpcurl
    just

    keybase
    gnupg

    docker

    nixfmt

    terminus-nerdfont
    inconsolata
    fantasque-sans-mono
    ankacoder
  ];
}
