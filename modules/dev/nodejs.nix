{ config, pkgs, ... }: {
  home.packages =  with pkgs; [
    nodejs
    yarn

    nodePackages.prettier
    # nodejs-16_x
    #(yarn.override {nodejs = nodejs-16_x;})
  ];


#  programs.zsh.initExtra = ''
#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
#[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" 
#'';

#   home.sessionVariables = {
#     GOPATH = "$(go env GOPATH)";
#     GOBIN = "$(go env GOBIN)";
#   };
}

