{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "albttx";
  home.homeDirectory = "/home/albttx";
  home.stateVersion = "22.05";
  home.extraOutputsToInstall = [ "doc" "info" "man" "devdoc" ];

  imports = [
    ./modules/ssh/default.nix
    ./modules/git/default.nix
    ./modules/shells/default.nix
    ./modules/dev/default.nix
    ./modules/neovim/default.nix
  ];

  home.packages =  with pkgs; [
    emacs
    ripgrep
    tree
    jq
    entr

    keybase
    gnupg

    docker

    nixfmt
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
