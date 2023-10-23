{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "albttx";
  home.homeDirectory = "/home/albttx";
  home.stateVersion = "23.05";
  home.extraOutputsToInstall = [ "doc" "info" "man" "devdoc" ];

  fonts.fontconfig.enable = true;

  imports = [
    ./packages.nix

    ./modules/ssh/default.nix
    ./modules/git/default.nix
    ./modules/shells/default.nix
    ./modules/dev/default.nix
    ./modules/neovim/default.nix
    ./modules/awesomewm/default.nix
    ./modules/picom/default.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
