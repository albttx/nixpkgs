{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    nodejs
    yarn

    nodePackages.prettier
    nodePackages.eslint
    # nodejs-16_x
    #(yarn.override {nodejs = nodejs-16_x;})
  ];

  programs.zsh.initContent = ''
    export PATH="$PATH:$HOME/.yarn/bin"
  '';
}
