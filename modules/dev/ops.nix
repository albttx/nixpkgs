{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Ansible suite tools
    ansible
    ansible-lint

    ctop

    ipcalc

    nomad

    awscli2
    minio-client
    scaleway-cli
  ];

}
