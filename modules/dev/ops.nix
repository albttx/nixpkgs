{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Ansible suite tools
    ansible
    ansible-lint

    nomad
  ];

}
