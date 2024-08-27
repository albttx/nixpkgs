{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs.pkgs-master;
    [
      # new code editor
      zed-editor
    ];
}
