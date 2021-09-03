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
vim.o.encoding = "utf8"
vim.o.completeopt = "menuone,noselect"
vim.g.forest_night_enable_italic = 1
vim.g.forest_night_diagnostic_text_highlight = 1
vim.g.mapleader = " "

vim.cmd [[set listchars=tab:»·,trail:·]]

-- Packer stuff

vim.cmd [[packadd packer.nvim]]

local startup = require("packer").startup

startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- language server configurations
  use "neovim/nvim-lspconfig"
  use "kabouzeid/nvim-lspinstall"

  -- autocomplete and snippets
  -- Install nvim-cmp, and buffer source as a dependency
  --use {
  --  "hrsh7th/nvim-cmp",
  --  requires = {
  --    "hrsh7th/vim-vsnip",
  --    "hrsh7th/cmp-buffer",
  --  }
  --}
  
  use "nvim-lua/completion-nvim"

  -- syntax highlighting
  use "nvim-treesitter/nvim-treesitter"

  -- file search
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }

  -- Git marks
  use "airblade/vim-gitgutter"

  -- Status bar
  use "itchyny/lightline.vim"

  -- Theme
  use {"npxbr/gruvbox.nvim", requires = {"rktjmp/lush.nvim"}}

  -- close pairs
  use "windwp/nvim-autopairs"
  use "rstacruz/vim-hyperstyle"

  -- Dev icons
  use "kyazdani42/nvim-web-devicons"

  -- File Explorer
  use "kyazdani42/nvim-tree.lua"
  
  -- Git blamer
  use "APZelos/blamer.nvim"

  -- Indentline
  use "Yggdroot/indentLine"

  -- Elixir Language support
  use "elixir-editors/vim-elixir"
end)

-- Theme
vim.cmd([[colorscheme gruvbox]])

-- LSP config

local function setup_servers()
  require'lspinstall'.setup()
  local servers = require'lspinstall'.installed_servers()
  for _, server in pairs(servers) do
    require'lspconfig'[server].setup{}
  end
end

setup_servers()

-- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
require'lspinstall'.post_install_hook = function ()
  setup_servers() -- reload installed servers
  vim.cmd("bufdo e") -- this triggers the FileType autocmd that starts the server
end

local lspconfig = require("lspconfig")

local on_attach = function(client, bufnr)
  local function map(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  local map_opts = {noremap = true, silent = true}

  map("n", "df", "<cmd>lua vim.lsp.buf.formatting()<cr>", map_opts)
  map("n", "gc", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>", map_opts)
  map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", map_opts)
  map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", map_opts)
  map("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", map_opts)
  map('n', "ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", map_opts)

  require"completion".on_attach(client)
end

local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  lintIgnoreExitCode = true,
  formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
  formatStdin = true
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local function eslint_config_exists()
  local eslintrc = vim.fn.glob(".eslintrc*", 0, 1)

  if not vim.tbl_isempty(eslintrc) then
    return true
  end

  if vim.fn.filereadable("package.json") then
    if vim.fn.json_decode(vim.fn.readfile("package.json"))["eslintConfig"] then
      return true
    end
  end

  return false
end

lspconfig.tsserver.setup {
  on_attach = on_attach
}

lspconfig.elixirls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    elixirLS = {
      dialyzerEnabled = true,
      fetchDeps = false
    }
  }
})

lspconfig.solargraph.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    solargraph = {
      diagnostics = true,
      completion = true
    }
  }
})

lspconfig.html.setup{
  capabilities = capabilities,
  on_attach = on_attach
}

lspconfig.efm.setup {
  on_attach = on_attach,
  root_dir = function()
    if not eslint_config_exists() then
      return nil
    end
    return vim.fn.getcwd()
  end,
  settings = {
    languages = {
      javascript = {eslint},
      javascriptreact = {eslint},
      ["javascript.jsx"] = {eslint},
      typescript = {eslint},
      ["typescript.tsx"] = {eslint},
      typescriptreact = {eslint}
    }
  },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescript.tsx",
    "typescriptreact"
  },
}


-- vim.api.nvim_command("autocmd BufEnter * lua require'completion'.on_attach()")

require('nvim-autopairs').setup{}

-- Tab through LSP

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  --elseif vim.fn.call("vsnip#available", {1}) == 1 then
    --return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  --elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
    --return t "<Plug>(vsnip-jump-prev)"
  else
    -- If <S-Tab> is not working in your terminal, change it to <C-h>
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})


-- Telescope config

vim.cmd [[nnoremap <leader>f <cmd>lua require('telescope.builtin').find_files()<cr>]]
vim.cmd [[nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>]]
vim.cmd [[nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>]]
vim.cmd [[nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>]]


-- Treesitter

local ts = require "nvim-treesitter.configs"
ts.setup {ensure_installed = "maintained", indent = {enable = true}, highlight = {enable = true}}


-- File Explorer

vim.cmd [[nnoremap <leader>n :NvimTreeToggle<CR>]]
vim.cmd [[nnoremap <leader>r :NvimTreeRefresh<CR>]]


-- Save and go back to insert mode
vim.cmd [[imap jj <Esc>:w<CR>a]]

