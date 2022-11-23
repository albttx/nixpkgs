{ config, pkgs, ... }: {
  programs.go = {
    enable = true;
    goPath = "golang";
    goBin = "go/bin";
    package = pkgs.go_1_19;
  };

  home.packages =  with pkgs; [
    golangci-lint
    gofumpt
    gopls
    gotags
    gotools
  ];

  # config.env.GOPATH = "$(go env GOPATH)";
  # home.sessionPath = [ "$HOME/${config.programs.go.goPath}/bin" ];
  home.sessionVariables = {
    GOPATH = "$(go env GOPATH)";
    LOL = "test123";
  };
}

