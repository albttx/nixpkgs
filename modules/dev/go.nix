{ config, pkgs, ... }:
{
  programs.go = {
    enable = true;
    package = pkgs.go_1_24;
    env = {
      GOPATH = "go";
      GOBIN = "go/bin";
    };
  };

  programs.zsh.initContent = ''
    export PATH="$GOPATH/bin:$PATH"
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
