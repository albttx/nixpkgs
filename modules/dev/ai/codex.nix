{ config, pkgs, ... }:

{
  # From master: codex moves too fast for the stable channel.
  home.packages = [ pkgs.pkgs-master.codex ];
}
