{ pkgs, lib, ... }:

let
  github-nvim-theme = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "github-nvim-theme";
    src = pkgs.fetchFromGitHub {
      owner = "projekt0n";
      repo = "github-nvim-theme";
      rev = "b3f15193d1733cc4e9c9fe65fbfec329af4bdc2a";
      sha256 = "wLX81wgl4E50mRig9erbLyrxyGbZllFbHFAQ9+v60W4=";
    };
  };

  go-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "go-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "ray-x";
      repo = "go.nvim";
      rev = "10349e1e430d00bc314c1d4abb043ac66ed219d9";
      sha256 = "15b18chsfgnkrlp996b07ih19gjxkqksghg02nknlid9vj2sf2d1";
    };
  };

in {
  home.packages = with pkgs;
    [
      # neovim
      silver-searcher
    ];

  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    withPython3 = true;
    # Disabled to avoid duplicate nodejs - nodejs is provided by modules/dev/nodejs.nix
    withNodeJs = false;
    withRuby = false;

    extraPython3Packages = (ps: with ps; [ pynvim ]);

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

      			function! GnoFmt()
      				cexpr system('gofmt -e -w ' . expand('%')) "or replace with gofumpt
      				edit!
      			endfunction
      			command! GnoFmt call GnoFmt()
      			augroup gno_autocmd
      				autocmd!
      				autocmd BufNewFile,BufRead *.gno set filetype=go
      				autocmd BufWritePost *.gno GnoFmt
      			augroup END
    '';

    plugins = with pkgs.vimPlugins; [
      vim-plug

      #nvim-autopairs
      auto-pairs
      fzf-vim
      # coc-nvim
      # coc-go

      vim-nix

      vim-polyglot

      nvim-tree-lua
      {
        plugin = github-nvim-theme;
        type = "lua";
        config = ''
          require('github-theme').setup {
            theme_style = "dark_default";
          }
        '';
      }
      {
        plugin = which-key-nvim;
        type = "lua";
        config = ''
          ------------------------------------- WHICH-KEY -----------------------------------------
          require("which-key").setup {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
          }
        '';
      }

      # vim-go
      {
        plugin = go-nvim;
        type = "lua";
        config = ''
          require('go').setup()

          local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
          vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*.go",
            callback = function()
             require('go.format').goimport()
            end,
            group = format_sync_grp,
          })
        '';
      }

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
            vim.api.nvim_set_keymap("n","<C-t>", ":Telescope<CR>", opts)
            vim.api.nvim_set_keymap("n","<C-p>", ":Telescope find_files<CR>", opts)
            vim.api.nvim_set_keymap("n","<C-b>", ":Telescope buffers<CR>", opts)
            vim.api.nvim_set_keymap("n","<C-g>", ":Telescope live_grep<CR>", opts)
            vim.api.nvim_set_keymap("n","<leader>t", ":Telescope help_tags<CR>", opts)
          EOF
        '';
      }
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          require('lspconfig').rust_analyzer.setup{}
          require('lspconfig').sumneko_lua.setup{}

          require('go').setup({
             lsp_cfg = true, -- setup gopls for us
             -- moved this into .gonvim per-project directory as this isn't usually what I want
             -- lsp_cfg = {
             --   settings= {
             --     gopls = {
             --       staticcheck=false,
             --     }
             --   }
             -- },
             lsp_on_attach = on_attach,
             --verbose = true,
             --tag_options = "json="
             tag_transform = "camelcase",
           })

        '';
      }

      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = ''
          require('nvim-treesitter.configs').setup {
            highlight = {
              enable = true,
              additional_vim_regex_highlighting = false,
            },
          }
        '';
      }

      {
        plugin = nightfox-nvim;
        type = "lua";
        config = builtins.readFile ./configs/nightfox-nvim.lua;
      }

      {
        plugin = bufferline-nvim;
        type = "lua";
        config = ''
          require("bufferline").setup {
            options = {
              numbers = "none",
              tab_size = 7,
              show_close_icon = false,
              close_command = safe_delete_buffer,
              right_mouse_command = safe_delete_buffer,
            }
          }
          require("which-key").register({
            ["<leader>"] = {
              ["}"] = {"<cmd>BufferLineCycleNext<cr>", "Next buffer"},
              ["{"] = {"<cmd>BufferLineCyclePrev<cr>", "Prev buffer"},
              b = {"<cmd>BufferLinePick<cr>", "Pick buffer to swap to"},
              d = {"<cmd>BufferLinePickClose<cr>", "Pick buffer to close"},
            }
          })
        '';
      }
    ];
  };

  programs.zsh = {
    initContent = ''
      export EDITOR="nvim"
    '';
  };
}
