{ config, pkgs, ... }:

{
  imports = [
    # modules
    ./go.nix
    ./rust.nix
    ./nodejs.nix
    ./direnv.nix
    ./ops.nix
    ./python.nix
  ];

  home.packages = with pkgs; [
    # basic dev tools
    jq

    tree

    # custom syntax color
    grc

    grpcurl
    httpie

    # basic watcher and exec
    # find . -name "*.go" | entr -c go test -v ./...
    entr

    watch

    hasura-cli

    pkgs-master.nhost-cli
    # pkgs-master.supabase-cli
  ];

  home.file.".grc" = {
    source = ./grc;
    recursive = true;
  };
}
