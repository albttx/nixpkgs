{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "albttx";
  home.homeDirectory = "/home/albttx";
  
  imports = [
    ./packages.nix
  ];


  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
