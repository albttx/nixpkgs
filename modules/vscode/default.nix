{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;

    profiles = {
      default = {
        extensions = [
          #golang.go
          #ms-python.python
          #ms-vscode.cpptools
          #esbenp.prettier-vscode
          #dbaeumer.vscode-eslint
          #hashicorp.terraform
        ];
      };
    };
  };
}

