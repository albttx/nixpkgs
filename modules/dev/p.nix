{ config, pkgs, ... }:

{
  # p, a project switcher for the GOPATH-style tree: https://github.com/albttx/p
  home.packages = [ pkgs.p ];

  home.sessionVariables = {
    CODE_DIR = "${config.home.homeDirectory}/go/src";
  };

  # p expands $HOME itself, so the literal string is fine here.
  xdg.configFile."p/config.yaml".text = ''
    code_dir: "$HOME/go/src/"
  '';

  # Order matters: `p init` defines the `p` shell function, and the
  # completion script binds to that name.
  programs.zsh.initContent = ''
    eval "$(${pkgs.p}/bin/p init zsh)"
    source <(${pkgs.p}/bin/p completion zsh)
  '';
}
