{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;

    extensions = [
      "ms-python.python"
      "ms-vscode.cpptools"
      "esbenp.prettier-vscode"
      "dbaeumer.vscode-eslint"
      "hashicorp.terraform"
      "golang.go"
    ];
  };
}

