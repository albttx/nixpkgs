{ config, pkgs, ... }:
{
  # Single source of node tooling (also used by emacs and neovim); avoid duplicate nodejs derivations.
  # neovim.withNodeJs is disabled to prevent it from adding its own nodejs.
  # Don't add nodejs explicitly - nodePackages.* will bring it in as a dependency.
  # This ensures we only have one nodejs derivation (the one nodePackages use).
  # nodejs will be available in PATH via nodePackages.npm's dependency.
  home.packages = with pkgs; [
    pkgs-master.bun

    yarn
    nodePackages.npm
    nodePackages.prettier
    nodePackages.eslint
    nodePackages.typescript-language-server
  ];

  programs.zsh.initContent = ''
    export PATH="$PATH:$HOME/.yarn/bin"
    export PATH="$PATH:$HOME/.bun/bin"
  '';
}
