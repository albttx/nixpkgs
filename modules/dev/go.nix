{ config, pkgs, ... }: {
  programs.go = {
    enable = true;
    goPath = "go";
    goBin = "go/bin";
    package = pkgs.go;
  };

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

