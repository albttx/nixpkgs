{ config, pkgs, ... }: {
  home.packages =  with pkgs; [
    nodejs
    yarn
  ];


  programs.zsh.initExtra = ''
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" 
'';

#   home.sessionVariables = {
#     GOPATH = "$(go env GOPATH)";
#     GOBIN = "$(go env GOBIN)";
#   };
}

