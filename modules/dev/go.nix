{ config, pkgs, ... }: {
  programs.go = {
    enable = true;
    goPath = "go";
    goBin = "go/bin";
    package = pkgs.go_1_20;
  };

  programs.zsh.initExtra = ''
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

