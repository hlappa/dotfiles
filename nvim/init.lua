-- Basic opts
local o = vim.opt

o.foldmethod = "syntax"
o.foldlevelstart = 99
o.smartindent = true
o.tabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.number = true
o.termguicolors = true
o.splitbelow = true
o.splitright = true
o.undofile = true
o.undodir = vim.fn.expand("~/.tmp")
o.showmode = false
o.incsearch = true
o.ignorecase = true
o.smartcase = true
o.mouse = "a"
o.errorbells = false
o.visualbell = true
o.inccommand = "nosplit"
o.background = "dark"
o.autoread = true
o.listchars = { trail = '·', tab = '»»' }
o.list = true
o.encoding = "utf-8"
o.completeopt = "menu,menuone,noselect"
o.clipboard = "unnamedplus"
vim.g.forest_night_enable_italic = 1
vim.g.forest_night_diagnostic_text_highlight = 1
vim.g.glow_binary_path = vim.env.HOME .. "/bin"
vim.g.mapleader = " "
vim.wo.relativenumber = true

local startup = require("packer").startup

startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- language server configurations
  use "neovim/nvim-lspconfig"
  use 'williamboman/nvim-lsp-installer'
  use "ray-x/lsp_signature.nvim"

  -- Indent colorscheme
  use "lukas-reineke/indent-blankline.nvim"

  -- Completion engine
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'

  -- Snippets
  use 'honza/vim-snippets'
  use 'rafamadriz/friendly-snippets'
  use 'hrsh7th/cmp-vsnip'
  use 'hrsh7th/vim-vsnip'
  use 'hrsh7th/vim-vsnip-integ'

  -- syntax highlighting
  use "nvim-treesitter/nvim-treesitter"

  -- Move code blocks or row
  use 'fedepujol/move.nvim'

  -- file search
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }

  -- Git
  use {
    'lewis6991/gitsigns.nvim',
    requires = 'nvim-lua/plenary.nvim',
  }

  -- Status bar
  use "hoob3rt/lualine.nvim"

  -- Notifications
  use 'rcarriga/nvim-notify'

  -- Theme
  use "ellisonleao/gruvbox.nvim"
  use "xiyaowong/nvim-transparent"

  -- Preview Markdown files
  use "ellisonleao/glow.nvim"

  -- close pairs
  use "windwp/nvim-autopairs"

  -- File explorer
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
  }

  -- Select similar words or sentences
  use "mg979/vim-visual-multi"

  -- Smooth scrolling
  use 'karb94/neoscroll.nvim'

  -- Trouble window
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function() require("trouble").setup {} end
  }

  -- Commenter
  use {
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup()
    end
  }

  -- Noice
  -- use({
  --   "folke/noice.nvim",
  --   event = "VimEnter",
  --   config = function()
  --     require("noice").setup({
  --       cmdline = {
  --         view = "cmdline",
  --       },
  --       popupmenu = {
  --         enabled = true,
  --         backend = 'cmp',
  --       },
  --     })
  --   end,
  --   requires = {
  --     -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
  --     "MunifTanjim/nui.nvim",
  --     -- OPTIONAL:
  --     --   `nvim-notify` is only needed, if you want to use the notification view.
  --     --   If not available, we use `mini` as the fallback
  --     "rcarriga/nvim-notify",
  --     }
  -- })

  -- Colorizer
  use "norcalli/nvim-colorizer.lua"

  -- Lightbulb for available code-action
  use 'kosayoda/nvim-lightbulb'

  -- Elixir language support since treesitter for elixir is broken
  use "elixir-editors/vim-elixir"
end)

-- Notofications setup
vim.notify = require("notify").setup({
  background_color = "#000000"
})

-- Theme
require("gruvbox").setup({
  undercurl = true,
  underline = true,
  bold = true,
  italic = true,
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = true, -- invert background for search, diffs, statuslines and errors
  contrast = "soft", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
})
vim.cmd("colorscheme gruvbox")

-- Nvim tree
require("nvim-tree").setup ({})

-- Order go imports helper function
function goimports(timeout_ms)
  local context = { only = { "source.organizeImports" } }
  vim.validate { context = { context, "t", true } }

  local params = vim.lsp.util.make_range_params()
  params.context = context

  -- See the implementation of the textDocument/codeAction callback
  -- (lua/vim/lsp/handler.lua) for how to do this properly.
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
  if not result or next(result) or result[1] == nil then return end
  local actions = result[1].result
  if not actions then return end
  local action = actions[1]

  -- textDocument/codeAction can return either Command[] or CodeAction[]. If it
  -- is a CodeAction, it can have either an edit, a command or both. Edits
  -- should be executed first.
  if action.edit or type(action.command) == "table" then
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit)
    end
    if type(action.command) == "table" then
      vim.lsp.buf.execute_command(action.command)
    end
  else
    vim.lsp.buf.execute_command(action)
  end
end

-- LSP config
local on_attach = function(client, bufnr)
  local function map(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  local map_opts = {noremap = true, silent = true}
  map("n", "df", "<cmd>lua vim.lsp.buf.formatting()<cr>", map_opts)
  map("n", "ge", "<cmd>lua vim.diagnostic.open_float()<cr>", map_opts)
  map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", map_opts)
  map("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", map_opts)
  map("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", map_opts)
  map('n', "ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", map_opts)
  map("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", map_opts)
  map("n", "<Leader>gr", "<cmd>lua vim.lsp.buf.references()<CR>", map_opts)

  -- Go import formatting & ordering
  vim.cmd("autocmd BufWritePre *.go lua goimports(1000)")

  -- format on save
  vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.format(nil, 300)")
end

-- Peek function signature when typing

-- Setup smooth scrolling
require('neoscroll').setup({
  mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb' }
})

-- Setup transparency
require("transparent").setup({
  enable = true, -- boolean: enable transparent
  extra_groups = { -- table/string: additional groups that should be clear
    -- In particular, when you set it to 'all', that means all available groups

    -- example of akinsho/nvim-bufferline.lua
    "bufferlinetabclose",
    "bufferlinebufferselected",
    "bufferlinefill",
    "bufferlinebackground",
    "bufferlineseparator",
    "bufferlineindicatorselected",
  },
  exclude = {}, -- table: groups you don't want to clear
})

o.termguicolors = true
vim.cmd("highlight IndentBlanklineIndent1 guibg=#1f1f1f gui=nocombine")
vim.cmd("highlight IndentBlanklineIndent2 guibg=#1a1a1a gui=nocombine")

require("indent_blankline").setup {
    char = "",
    char_highlight_list = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
    },
    space_char_highlight_list = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
    },
    show_trailing_blankline_indent = false,
    show_current_context = true,
    show_current_context_start = true,
}

-- Setup CPM
local cmp = require'cmp'

local kind_icons = {
  Text = "",
  Method = "",
  Function = "",
  Constructor = "",
  Field = "",
  Variable = "",
  Class = "ﴯ",
  Interface = "",
  Module = "",
  Property = "ﰠ",
  Unit = "",
  Value = "",
  Enum = "",
  Keyword = "",
  Snippet = "",
  Color = "",
  File = "",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "",
  Struct = "",
  Event = "",
  Operator = "",
  TypeParameter = ""
}

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
  }, {
    { name = 'buffer' },
  }),
  formatting = {
    format = function(entry, vim_item)
      vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
      vim_item.menu = ({
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        nvim_lua = "[Lua]",
        vsnip = "[VSnip]"
      })[entry.source.name]
      return vim_item
    end
  }
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Setup Gitsigns
require('gitsigns').setup {
  on_attach = function(bufnr)
    local function map(mode, lhs, rhs, opts)
        opts = vim.tbl_extend('force', {noremap = true, silent = true}, opts or {})
        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
    end

    -- Navigation
    map('n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", {expr=true})
    map('n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", {expr=true})

    -- Actions
    map('n', '<leader>hs', '<cmd>Gitsigns stage_hunk<CR>')
    map('v', '<leader>hs', '<cmd>Gitsigns stage_hunk<CR>')
    map('n', '<leader>hr', '<cmd>Gitsigns reset_hunk<CR>')
    map('v', '<leader>hr', '<cmd>Gitsigns reset_hunk<CR>')
    map('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<CR>')
    map('n', '<leader>hu', '<cmd>Gitsigns undo_stage_hunk<CR>')
    map('n', '<leader>hR', '<cmd>Gitsigns reset_buffer<CR>')
    map('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<CR>')
    map('n', '<leader>hb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
    map('n', '<leader>tb', '<cmd>Gitsigns toggle_current_line_blame<CR>')
    map('n', '<leader>hd', '<cmd>Gitsigns diffthis<CR>')
    map('n', '<leader>hD', '<cmd>lua require"gitsigns".diffthis("~")<CR>')
    map('n', '<leader>td', '<cmd>Gitsigns toggle_deleted<CR>')

    -- Text object
    map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
local lspconfig = require("lspconfig")

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

lspconfig.gopls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gotmpl" },
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  }
})

lspconfig.terraformls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

lspconfig.tflint.setup({
  on_attach = on_attach
})

lspconfig.tsserver.setup({
  on_attach = function(client, bufnr) 
    -- disable tsserver formatting
    client.resolved_capabilities.document_formatting = false

    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  root_dir = function() return vim.loop.cwd() end,
  init_options = {
    preferences = {
      includeCompletionsWithSnippetText = true,
      includeCompletionsForImportStatements = true,
    }
  }
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

local prettier = {
  formatCommand = "prettier_d_slim --stdin --stdin-filepath ${INPUT}",
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
  on_attach = function(client, bufnr)
    client.resolved_capabilities.document_formatting = true
    client.resolved_capabilities.goto_definition = false
    on_attach(client, bufnr)
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
      javascript = {prettier},
      javascriptreact = {prettier},
      json = {prettier},
      scss = {prettier},
      css = {prettier},
      yaml = {prettier},
      html = {prettier},
      ["javascript.jsx"] = {prettier},
      typescript = {prettier},
      ["typescript.tsx"] = {prettier},
      typescriptreact = {prettier}
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

lspconfig.eslint.setup {
  on_attach = function(client, bufnr)
  end,
  capabilities = capabilities
}

-- Setup autopairing
local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

npairs.setup({ map_bs = false })

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
vim.cmd("nnoremap ff <cmd>lua require('telescope.builtin').find_files()<cr>")
vim.cmd("nnoremap fg <cmd>lua require('telescope.builtin').live_grep()<cr>")
vim.cmd("nnoremap fb <cmd>lua require('telescope.builtin').buffers()<cr>")
vim.cmd("nnoremap fh <cmd>lua require('telescope.builtin').help_tags()<cr>")

-- Treesitter
local ts = require "nvim-treesitter.configs"
ts.setup {
  ensure_installed = "all", 
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

-- Move maps
vim.api.nvim_set_keymap('n', '<C-j>', ":MoveLine(1)<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', ":MoveLine(-1)<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-j>', ":MoveBlock(1)<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-k>', ":MoveBlock(-1)<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', ":MoveHChar(1)<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-h>', ":MoveHChar(-1)<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-l>', ":MoveHBlock(1)<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-h>', ":MoveHBlock(-1)<CR>", { noremap = true, silent = true })

-- File Explorer
vim.api.nvim_set_keymap('n', '<Leader>r', ':NvimTreeRefresh<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>n', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- splitting
vim.api.nvim_set_keymap('n', '<Leader>s', ':sp<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>v', ':vs<CR>', { noremap = true, silent = true })

-- Markdown preview shortcut
vim.api.nvim_set_keymap('n', '<leader>p', ':Glow<CR>', { noremap = true, silent = true })

-- Open Trouble
vim.api.nvim_set_keymap("n", "<leader>xx", "<cmd>Trouble<cr>", { silent = true, noremap = true })

-- Save and go back to insert mode
vim.api.nvim_set_keymap('i', 'jj', "<Esc>:w<CR>a", {})

-- Go to normal mode
vim.api.nvim_set_keymap('i', 'jk', "<Esc>", {})

-- Open nvim tree on startup
vim.api.nvim_command("autocmd VimEnter * NvimTreeToggle")
