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
vim.g.glow_binary_path = vim.env.HOME .. "/bin"
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
  use "ms-jpq/coq_nvim"
  use "ms-jpq/coq.artifacts"

  -- syntax highlighting
  use "nvim-treesitter/nvim-treesitter"

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
  use "hoob3rt/lualine.nvim"

  -- Theme
  use {"npxbr/gruvbox.nvim", requires = {"rktjmp/lush.nvim"}}

  -- Preview Markdown files
  use "ellisonleao/glow.nvim"

  -- close pairs
  use "windwp/nvim-autopairs"
  use "rstacruz/vim-hyperstyle"

  -- File explorer
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function() require'nvim-tree'.setup {} end
  }

  -- Commenter
  use {
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup()
    end
  }

  -- Git blame
  use "f-person/git-blame.nvim"

  -- Elixir Language support
  use "elixir-editors/vim-elixir"
end)

-- Theme
vim.g["gruvbox_contrast_dark"] = "hard"
vim.cmd([[colorscheme gruvbox]])

local coq = require "coq"

-- LSP config
local on_attach = function(client, bufnr)
  local function map(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  local map_opts = {noremap = true, silent = true}

  map("n", "df", "<cmd>lua vim.lsp.buf.formatting()<cr>", map_opts)
  map("n", "ge", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>", map_opts)
  map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", map_opts)
  map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", map_opts)
  map("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", map_opts)
  map('n', "ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", map_opts)

  -- format on save
  vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting()")
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
    lspconfig[server].setup(coq.lsp_ensure_capabilities())
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

lspconfig.typescript.setup({
  on_attach = function(client, bufnr) 
    local function map(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

    local map_opts = {noremap = true, silent = true}

    map("n", "df", "<cmd>lua vim.lsp.buf.formatting()<CR>", map_opts)
    map("n", "ge", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>", map_opts)
    map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", map_opts)
    map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", map_opts)
    map("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", map_opts)
    map('n', "ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", map_opts)

    -- disable tsserver formatting
    client.resolved_capabilities.document_formatting = false

    -- format on save
    vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting()")
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

local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  lintIgnoreExitCode = true,
  formatCommand = "eslint_d --stdin --fix-to-stdout --stdin-filename=${INPUT}",
  formatStdin = true
}

local prettier = {
  formatCommand = 'prettier --stdin-filepath ${INPUT}',
  formatStdin = true
}

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

lspconfig.efm.setup {
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = true
    client.resolved_capabilities.goto_definition = false
    on_attach(client)
  end,
  init_options = {
    documentFormatting = true,
    document_formatting = true
  },
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
      json = {prettier},
      scss = {prettier},
      css = {prettier},
      yaml = {prettier},
      html = {prettier},
      ["javascript.jsx"] = {eslint},
      typescript = {eslint},
      ["typescript.tsx"] = {eslint},
      typescriptreact = {eslint}
    }
  },
  cmd = { "/home/aleksi/go/bin/efm-langserver" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescript.tsx",
    "typescriptreact"
  },
}

-- Setup autopairing
local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

npairs.setup({ map_bs = false })

vim.g.coq_settings = { keymap = { recommended = false } }

_G.MUtils= {}

MUtils.CR = function()
  if vim.fn.pumvisible() ~= 0 then
    if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
      return npairs.esc('<c-y>')
    else
      return npairs.esc('<c-e>') .. npairs.autopairs_cr()
    end
  else
    return npairs.autopairs_cr()
  end
end
remap('i', '<cr>', 'v:lua.MUtils.CR()', { expr = true, noremap = true })

MUtils.BS = function()
  if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({ 'mode' }).mode == 'eval' then
    return npairs.esc('<c-e>') .. npairs.autopairs_bs()
  else
    return npairs.autopairs_bs()
  end
end
remap('i', '<bs>', 'v:lua.MUtils.BS()', { expr = true, noremap = true })

-- Tab through completion
remap('i', '<esc>', [[pumvisible() ? "<c-e><esc>" : "<esc>"]], { expr = true, noremap = true })
remap('i', '<c-c>', [[pumvisible() ? "<c-e><c-c>" : "<c-c>"]], { expr = true, noremap = true })
remap('i', '<tab>', [[pumvisible() ? "<c-n>" : "<tab>"]], { expr = true, noremap = true })
remap('i', '<s-tab>', [[pumvisible() ? "<c-p>" : "<bs>"]], { expr = true, noremap = true })

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

-- Lualine
require('lualine').setup({
  options = {
    theme = 'gruvbox'
  },
  sections = {
    lualine_c = {
      {
        'filename',
        filestatus = true,
        path = 2,
      }
    }
  }
})

-- File Explorer
vim.api.nvim_set_keymap('n', '<Leader>r', ':NvimTreeRefresh<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>n', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Markdown preview shortcut
vim.api.nvim_set_keymap('n', '<leader>p', ':Glow<CR>', { noremap = true, silent = true })

-- Save and go back to insert mode
vim.api.nvim_set_keymap('i', 'jj', "<Esc>:w<CR>a", {})

-- Open nvim tree on startup
vim.api.nvim_command("autocmd VimEnter * NvimTreeToggle")

-- Start COQ
vim.cmd('COQnow -s')
