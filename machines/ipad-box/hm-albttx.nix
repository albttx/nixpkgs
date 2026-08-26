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

  # Shortcut to the dotfiles clone.
  home.file."nixpkgs".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/go/src/github.com/albttx/nixpkgs";

  # The GPG signing key only lives on the laptop; signing every commit
  # here would just fail.
  programs.git.signing.signByDefault = lib.mkForce false;

  # modules/ssh points github.com at ~/.ssh/albttx (the laptop key); this
  # machine has its own deploy key instead (registered on GitHub as "ipad-box").
  programs.ssh.settings."github.com".IdentityFile = lib.mkForce "~/.ssh/ipad-box";

  # SSH clients only forward TERM, so sessions land here as xterm-256color
  # with no truecolor capability and emacs degrades doom-one to the 256-color
  # palette (which some terminal apps then render badly). Every terminal we
  # actually connect from (kitty, Termius, iTerm) speaks 24-bit color; emacs
  # and friends trust COLORTERM over terminfo.
  programs.zsh.initContent = ''
    export COLORTERM=truecolor
  '';

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
