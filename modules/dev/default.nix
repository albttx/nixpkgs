{ config, pkgs, ... }:

{
  imports = [ ./go.nix ./nodejs.nix ./direnv.nix ./ops.nix ];

  home.packages = with pkgs; [
    # basic dev tools
    jq

    grpcurl
  ];


}
