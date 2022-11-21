{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # neovim
  ];

  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    withPython3 = true;
    withNodeJs = true;
    withRuby = false;

    extraPython3Packages = (ps: with ps; [
      pynvim
    ]);

    extraConfig = ''
      set expandtab
      set tabstop=2
      set softtabstop=2
      set shiftwidth=2
      set number
      set list
      set noswapfile
      set encoding=UTF-8
      let mapleader=" "
    '';

    plugins = with pkgs.vimPlugins; [
      vim-plug

      #nvim-autopairs
      auto-pairs
      fzf-vim
      # coc-nvim
      # coc-go

      vim-nix
      vim-go

      vim-airline
      vim-airline-themes

      {
        plugin = telescope-nvim;
        config = ''
        lua << EOF
          local telescope = require'telescope'
          telescope.setup{}
          -- telescope.load_extension('fzf')
          local opts = { noremap = true }
          vim.api.nvim_set_keymap("n","<C-p>", ":Telescope find_files<CR>", opts)
          vim.api.nvim_set_keymap("n","<C-t>", ":Telescope<CR>", opts)
          vim.api.nvim_set_keymap("n","<C-g>", ":Telescope live_grep<CR>", opts)
          vim.api.nvim_set_keymap("n","<leader>t", ":Telescope help_tags<CR>", opts)
        EOF
        '';
      }
      {
        plugin = nvim-lspconfig;
        config = ''
          lua << EOF
            require('lspconfig').rust_analyzer.setup{}
            require('lspconfig').sumneko_lua.setup{}
          EOF
        '';
      }

      {
        plugin = nvim-treesitter;
        config = ''
          lua << EOF
            require('nvim-treesitter.configs').setup {
              highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
              },
            }
          EOF
        '';
      }


      {
        type = "lua";
        plugin = nightfox-nvim;
        config = builtins.readFile ./configs/nightfox-nvim.lua;
      }
    ];
  };

  programs.zsh = {
    initExtra = ''
      export EDITOR="nvim"
    '';
  };
}
