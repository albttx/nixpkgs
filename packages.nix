{ pkgs, lib, ... }:

{
  home.extraOutputsToInstall = [ "doc" "info" "man" "devdoc" ];

  imports = [
    ./modules/ssh/default.nix
    ./modules/git/default.nix
    ./modules/shells/default.nix
    ./modules/neovim/default.nix
  ];

  home.packages =  with pkgs; [
    go_1_19
    emacs
    ripgrep
    tree
    jq
    entr

    docker

    golangci-lint
    # pkgs.gofumpt
    gopls
    gotags
    gotools
  ];
}
