{ pkgs, ... }:

{
  # From master: opencode moves too fast for the stable channel.
  home.packages = [ pkgs.pkgs-master.opencode ];
}
