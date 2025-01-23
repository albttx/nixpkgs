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

    extraConfig = ''
      IdentityAgent "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';

  };

  home.packages = with pkgs; [ openssh ];
}
