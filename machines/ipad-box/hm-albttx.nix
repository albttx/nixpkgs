# Home-manager config for albttx on ipad-box. Used twice:
#  - imported into the NixOS module in ./hm.nix (applied by `nixos-rebuild switch`)
#  - as the standalone homeConfigurations."ipad-box" flake output
#    (applied by `make switch.home-manager` without a system rebuild)
{
  inputs,
  outputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  home.stateVersion = "26.05";
  home.username = "albttx";
  home.homeDirectory = "/home/albttx";

  imports = [
    ../../modules/ssh
    ../../modules/git
    ../../modules/gpg

    # programming
    ../../modules/dev

    # import zsh, fzf, tmux config
    ../../modules/shells

    # import editors
    ../../modules/neovim
    ../../modules/emacs
  ];

  programs.home-manager.enable = true;

  # The GPG signing key only lives on the laptop; signing every commit
  # here would just fail.
  programs.git.signing.signByDefault = lib.mkForce false;

  home.packages = with pkgs; [
    # build tool
    coreutils
    curl
    wget

    # headless server: terminal emacs for the doom config
    emacs-nox
    my-libvterm
  ];
}
