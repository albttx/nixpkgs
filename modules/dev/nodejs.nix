{ config, pkgs, ... }:
{
  # Single source of node tooling (also used by emacs and neovim); avoid duplicate nodejs derivations.
  # neovim.withNodeJs is disabled to prevent it from adding its own nodejs.
  # `nodePackages` was removed in nixpkgs 26.05; npm now ships with the `nodejs` derivation
  # and the rest are top-level packages.
  home.packages = with pkgs; [
    pkgs-master.bun

    yarn
    nodejs
    prettier
    eslint
    typescript-language-server
  ];

  programs.zsh.initContent = ''
    export PATH="$PATH:$HOME/.yarn/bin"
    export PATH="$PATH:$HOME/.bun/bin"
  '';
}
