-- Basic opts
local opt = vim.opt

opt.foldmethod = "syntax"
opt.foldlevelstart = 99
opt.smartindent = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.number = true
opt.termguicolors = true
opt.splitbelow = true
opt.splitright = true
opt.lazyredraw = true
opt.showmode = false
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.undofile = true
opt.undodir = vim.fn.expand("~/.tmp")
opt.mouse = "a"
opt.errorbells = false
opt.visualbell = true
opt.inccommand = "nosplit"
opt.background = "dark"
opt.autoread = true
opt.listchars = { tab = '»»', trail = '·' }
vim.o.encoding = "utf-8"
vim.o.completeopt = "menuone,noinsert,noselect"
vim.g.forest_night_enable_italic = 1
vim.g.forest_night_diagnostic_text_highlight = 1
vim.g.mapleader = " "

-- Packer stuff
vim.cmd [[packadd packer.nvim]]

local startup = require("packer").startup

startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- language server configurations
  use "neovim/nvim-lspconfig"
  use "kabouzeid/nvim-lspinstall"

  -- Complention engine
  use "nvim-lua/completion-nvim"
  use 'hrsh7th/vim-vsnip'
  use 'hrsh7th/vim-vsnip-integ'

  -- syntax highlighting
  use "nvim-treesitter/nvim-treesitter"

  -- Eslint for TS, JS etc
  use {
    "jose-elias-alvarez/nvim-lsp-ts-utils",
    requires = {{'nvim-lua/plenary.nvim'}, {"jose-elias-alvarez/null-ls.nvim"}}
  }

  -- file search
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }

  -- Git marks
  use "airblade/vim-gitgutter"

  -- Git plugin
  use "tpope/vim-fugitive"

  -- Status bar
  use "itchyny/lightline.vim"

  -- Theme
  use {"npxbr/gruvbox.nvim", requires = {"rktjmp/lush.nvim"}}

  -- close pairs
  use "windwp/nvim-autopairs"
  use "rstacruz/vim-hyperstyle"

  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function() require'nvim-tree'.setup {} end
  }

  -- Git blamer
  use "APZelos/blamer.nvim"

  -- Elixir Language support
  use "elixir-editors/vim-elixir"
end)

vim.g["completion_enable_snippet"] = "vim-vsnip"

-- Theme
vim.g["gruvbox_contrast_dark"] = "hard"
vim.cmd([[colorscheme gruvbox]])

-- LSP config
local on_attach = function(client, bufnr)
  local function map(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  local map_opts = {noremap = true, silent = true}

  map("n", "df", "<cmd>lua vim.lsp.buf.formatting()<cr>", map_opts)
  map("n", "gc", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>", map_opts)
  map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", map_opts)
  map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", map_opts)
  map("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", map_opts)
  map('n', "ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", map_opts)

  -- format on save
  vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting()")

  require"completion".on_attach(client)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local lspconfig = require("lspconfig")

local function setup_servers()
  require'lspinstall'.setup()
  local servers = require'lspinstall'.installed_servers()
  for _, server in pairs(servers) do
    lspconfig[server].setup{
      on_attach = on_attach,
      capabilities = capabilities
    }
  end
end

setup_servers()

-- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
require'lspinstall'.post_install_hook = function ()
  setup_servers() -- reload installed servers
  vim.cmd("bufdo e") -- this triggers the FileType autocmd that starts the server
end

lspconfig.elixirls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "/home/aleksi/.elixir-ls/language_server.sh" },
  settings = {
    elixirLS = {
      dialyzerEnabled = true,
      fetchDeps = false
    }
  }
})

-- Custom on-attach for typescript since we also need eslint, prettier along with tsserver
require("null-ls").config {}
lspconfig["null-ls"].setup {}

lspconfig.typescript.setup({
  on_attach = function(client, bufnr) 
    local function map(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

    local map_opts = {noremap = true, silent = true}

    map("n", "df", "<cmd>lua vim.lsp.buf.formatting()<cr>", map_opts)
    map("n", "gc", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>", map_opts)
    map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", map_opts)
    map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", map_opts)
    map("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", map_opts)
    map('n', "ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", map_opts)

    local ts_utils = require("nvim-lsp-ts-utils")

    -- disable tsserver formatting
    client.resolved_capabilities.document_formatting = false

    ts_utils.setup {
      enable_import_on_completion = true,
      eslint_bin = "eslint_d",
      eslint_enable_diagnostics = true,
      enable_formatting = true,
      formatter = "prettier",
      formatter_opts = {},
    }

    ts_utils.setup_client(client)

    -- format on save
    vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting()")

    require"completion".on_attach(client)
  end,
  capabilities = capabilities,
  root_dir = function() return vim.loop.cwd() end
})

lspconfig.solargraph.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    solargraph = {
      diagnostics = true,
      completion = true
    }
  },
  root_dir = function() return vim.loop.cwd() end
})

-- Setup autopairing
require('nvim-autopairs').setup{}

-- Tab through completion
vim.cmd [[inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"]]
vim.cmd [[inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"]]

-- Telescope config
vim.cmd [[nnoremap <leader>f <cmd>lua require('telescope.builtin').find_files()<cr>]]
vim.cmd [[nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>]]
vim.cmd [[nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>]]
vim.cmd [[nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>]]

-- Treesitter
local ts = require "nvim-treesitter.configs"
ts.setup {
  ensure_installed = "maintained", 
  indent = {enable = true}, 
  highlight = {enable = true}
}

-- File Explorer
-- vim.cmd [[nnoremap <leader>n :NvimTreeToggle<CR>]]
vim.cmd [[nnoremap <leader>r :NvimTreeRefresh<CR>]]

vim.api.nvim_set_keymap('n', '<Leader>n', ':NvimTreeToggle<CR>', { noremap = true, silent = true })


-- Save and go back to insert mode
vim.cmd [[imap jj <Esc>:w<CR>a]]

-- Open nvim tree on startup
vim.api.nvim_command("autocmd VimEnter * NvimTreeToggle")
