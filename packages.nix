{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # emacs
    # 28.2 + native-comp
    ((emacsPackagesFor emacsNativeComp).emacsWithPackages
      (epkgs: [ epkgs.vterm ]))

    ripgrep
    tree
    jq
    entr

    grpcurl
    just

    keybase
    gnupg

    docker

    nixfmt

    terminus-nerdfont
    inconsolata
    fantasque-sans-mono
    ankacoder
  ];
}
