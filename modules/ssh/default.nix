{ pkgs, config, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        ControlMaster = "no";
        ForwardAgent = true;
        HashKnownHosts = true;
      };
      "github.com" = {
        IdentityFile = "~/.ssh/albttx";
        HostName = "github.com";
      };
    };

    extraConfig = ''
      IdentityAgent "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';

  };

  home.packages = with pkgs; [ openssh ];
}
