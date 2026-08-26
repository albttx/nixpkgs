{ config, pkgs, ... }:

{
  # nixpkgs names the Grok coding CLI `grok-build` (grok-cli is the older,
  # abandoned client). From master to keep up with releases.
  home.packages = [ pkgs.pkgs-master.grok-build ];
}
