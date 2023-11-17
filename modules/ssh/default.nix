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
    };
  };

  home.packages = with pkgs; [ openssh ];
}
