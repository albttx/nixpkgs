{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = false;
    withNodeJs = false; # nodejs comes from modules/dev/nodejs.nix
    withRuby = false;

    extraPackages = with pkgs; [
      ripgrep
      fd
      lua-language-server
      nil
      nixfmt
      stylua
      rust-analyzer
      gopls
      gofumpt
      gotools
    ];

    plugins = with pkgs.vimPlugins; [
      nightfox-nvim
      nvim-web-devicons
      lualine-nvim
      nvim-tree-lua
      plenary-nvim
      telescope-nvim
      telescope-fzf-native-nvim
      which-key-nvim
      nvim-treesitter.withAllGrammars
      nvim-lspconfig
      blink-cmp
      gitsigns-nvim
      nvim-autopairs
      nvim-surround
      conform-nvim
    ];

    initLua = builtins.readFile ./configs/init.lua;
  };

  programs.zsh.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };
}
