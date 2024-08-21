{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs;
    [
      # new code editor
      zed-editor
    ];
}
