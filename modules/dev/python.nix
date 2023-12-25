{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs;
    [

      (python3.withPackages (ps:
        with ps; [
          # List of python packages to install
          ansible
          pyyaml
          requests
          boto3
          bech32
        ]))
    ];
}
