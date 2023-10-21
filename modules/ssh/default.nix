{ pkgs, config, ... }:

{
  programs.ssh = {
    enable = true;
    controlMaster = "no";
    forwardAgent = true;
    hashKnownHosts = true;

    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/albttx";
        hostname = "github.com";
      };

      # nysa.network
      ######################################################
      "evmos-validator-01" = {
        hostname = "51.159.66.123";
        user = "albttx";
        identityFile = "~/.ssh/scaleway";
      };

      "validator-monitoring-01" = {
        user = "albttx";
        hostname = "51.15.177.223";
      };

      "juno-mainnet-01" = {
        user = "albttx";
        hostname = "163.172.101.4";
      };

      "stargaze-mainnet-01" = {
        user = "albttx";
        hostname = "163.172.100.37";
      };

      "ki-mainnet-01" = {
        user = "albttx";
        hostname = "51.159.29.54";
      };

      "orai-mainnet-01" = {
        user = "albttx";
        hostname = "51.159.29.22 ";
      };

      "checq-mainnet-01" = {
        user = "albttx";
        hostname = "163.172.57.117";
      };

      "evmos-mainnet-01" = {
        user = "albttx";
        hostname = "163.172.100.84";
      };

      "evmos-testnet-01" = {
        user = "albttx";
        hostname = "51.159.36.3";
      };

      # Interop
      ######################################################

      "interop-evmos-01" = {
        user = "scouture";
        hostname = "178.63.74.30";
      };

      "interop-quicksilver-innuendo-01" = {
        user = "interop";
        hostname = "51.15.18.184";
      };
    };
  };

  home.packages = with pkgs; [ openssh ];
}
