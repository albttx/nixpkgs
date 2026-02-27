{ config, pkgs, ... }:
{
  programs.go = {
    enable = true;
    package = pkgs.pkgs-master.go_1_25;
    env = {
      GOPATH = "${config.home.homeDirectory}/go";
      GOBIN = "${config.home.homeDirectory}/go/bin";
    };
  };

  programs.zsh.initContent = ''
    export PATH="${config.home.homeDirectory}/go/bin:$PATH"
  '';

  home.packages = with pkgs; [
    golangci-lint
    gofumpt
    gopls
    gotags
    gotools
    gotest

    gotests
    gomodifytags
    gore
  ];
}
