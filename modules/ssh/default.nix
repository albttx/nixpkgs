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

    # Proton Pass SSH agent only exists on the Mac.
    extraConfig = lib.optionalString pkgs.stdenv.isDarwin ''
      IdentityAgent "${config.home.homeDirectory}/.ssh/proton-pass-ssh-agent.sock"
    '';

  };

  home.packages = with pkgs; [ openssh ];
}
