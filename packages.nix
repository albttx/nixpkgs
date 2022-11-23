{ pkgs, lib, ... }:

{
  home.extraOutputsToInstall = [ "doc" "info" "man" "devdoc" ];

  imports = [
    ./modules/ssh/default.nix
    ./modules/git/default.nix
    ./modules/shells/default.nix
    ./modules/dev/default.nix
    ./modules/neovim/default.nix
    ./modules/awesomewm/default.nix
  ];

  home.packages =  with pkgs; [
    emacs
    ripgrep
    tree
    jq
    entr

    docker

    nixfmt
  ];
}
