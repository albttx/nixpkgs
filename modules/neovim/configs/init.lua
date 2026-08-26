-- Comfortable minimum Neovim 0.12 config.

-- nvim-tree: disable netrw before anything else
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- Space is the leader: don't move the cursor while which-key waits.
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.smartindent = true
opt.list = true
opt.swapfile = false
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.scrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.updatetime = 250
opt.timeoutlen = 400
opt.completeopt = { "menu", "menuone", "noselect" }
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.encoding = "utf-8"

-- Gno files are Go dialect.
vim.filetype.add({ extension = { gno = "go" } })
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.gno",
  callback = function(ev)
    vim.fn.system({ "gofmt", "-e", "-w", ev.file })
    vim.cmd.checktime()
  end,
})

-- Treesitter (nvim-treesitter main / 0.10 API). Parsers come from Nix.
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
    pcall(function()
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end)
  end,
})

require("nightfox").setup({ options = { transparent = true } })
vim.cmd.colorscheme("nightfox")

local wk = require("which-key")
wk.setup({ preset = "modern" })
require("lualine").setup({
  options = { theme = "nightfox", globalstatus = true },
})
require("gitsigns").setup()
require("nvim-autopairs").setup()
require("nvim-surround").setup()
require("nvim-tree").setup({
  view = { width = 32 },
  renderer = { group_empty = true },
  filters = { dotfiles = false },
})

local telescope = require("telescope")
telescope.setup({})
pcall(telescope.load_extension, "fzf")

require("conform").setup({
  formatters_by_ft = {
    go = { "gofumpt", "goimports" },
    nix = { "nixfmt" },
    lua = { "stylua" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
})

require("blink.cmp").setup({
  keymap = { preset = "enter" },
  appearance = { nerd_font_variant = "mono" },
  completion = { documentation = { auto_show = true } },
  sources = { default = { "lsp", "path", "buffer" } },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})

-- Native LSP (nvim-lspconfig provides server configs on rtp).
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
    },
  },
})
vim.lsp.enable({
  "gopls",
  "lua_ls",
  "nil_ls",
  "rust_analyzer",
  "ts_ls",
})

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

-- `<leader>f` must stay a prefix (find), not a complete map.
-- Binding it to format made `SPC ff` fire format after timeoutlen.
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", "Find files")
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", "Live grep")
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", "Buffers")
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", "Help tags")
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", "Recent files")
map("n", "<leader><leader>", "<cmd>Telescope find_files<cr>", "Find files")
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", "File tree")
map("n", "<leader>w", "<cmd>write<cr>", "Write")
map("n", "<leader>q", "<cmd>quit<cr>", "Quit")
map("n", "<leader>cf", function()
  require("conform").format({ async = true })
end, "Format buffer")
map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
map("n", "gd", vim.lsp.buf.definition, "Go to definition")
map("n", "<C-p>", "<cmd>Telescope find_files<cr>", "Find files")
map("n", "<C-g>", "<cmd>Telescope live_grep<cr>", "Live grep")
map("n", "<C-b>", "<cmd>Telescope buffers<cr>", "Buffers")
map("n", "<C-t>", "<cmd>Telescope<cr>", "Telescope")

wk.add({
  { "<leader>f", group = "find" },
  { "<leader>c", group = "code" },
})
