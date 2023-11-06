{ config, pkgs, ... }:

{
  imports = [ ./go.nix ./nodejs.nix ./direnv.nix ./ops.nix ./python.nix ];

  home.packages = with pkgs; [
    # basic dev tools
    jq

    grpcurl
    httpie

    # basic watcher and exec
    # find . -name "*.go" | entr -c go test -v ./...
    entr

    watch
  ];


}
