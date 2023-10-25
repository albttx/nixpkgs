{ config, pkgs, ... }:

{
  imports = [ ./go.nix ./nodejs.nix ./direnv.nix ./ops.nix ];
}
