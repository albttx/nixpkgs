{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    pkgs-master.nodejs
    pkgs-master.yarn

    nodePackages.prettier
    nodePackages.eslint
  ];

  programs.zsh.initContent = ''
    export PATH="$PATH:$HOME/.yarn/bin"
  '';
}
