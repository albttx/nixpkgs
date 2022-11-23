{ config, pkgs, ... }: {
  programs.go = {
    enable = true;
    goPath = "go";
    goBin = "go/bin";
    package = pkgs.go_1_19;
  };

  home.packages =  with pkgs; [
    golangci-lint
    gofumpt
    gopls
    gotags
    gotools
    gotest
  ];

  home.sessionVariables = {
    GOPATH = "$(go env GOPATH)";
    GOBIN = "$(go env GOBIN)";
  };
}

