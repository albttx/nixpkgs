{ config, pkgs, ... }:

{
  # From master: claude-code moves too fast for the stable channel.
  home.packages = [ pkgs.pkgs-master.claude-code ];
}
