{
  pkgs,
  config,
  lib,
  ...
}:

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

    # 1Password SSH agent only exists on the Mac.
    extraConfig = lib.optionalString pkgs.stdenv.isDarwin ''
      IdentityAgent "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';

  };

  home.packages = with pkgs; [ openssh ];
}
