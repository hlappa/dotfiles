local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Telescope
  { 'nvim-telescope/telescope.nvim',   dependencies = { 'nvim-lua/plenary.nvim' } },

  -- Treesitter
  { 'nvim-treesitter/nvim-treesitter', cmd = 'TSUpdate' },

  -- LSP
  {
    'VonHeikemen/lsp-zero.nvim',
    dependencies = {
      -- LSP Support
      'neovim/nvim-lspconfig',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Autocompletion
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',

      -- Snippets
      'L3MON4D3/LuaSnip',
      'rafamadriz/friendly-snippets',
    }
  },
  'VidocqH/lsp-lens.nvim',

  -- Trouble <leader>xx
  {
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("trouble").setup {}
    end
  },

  -- Renaming
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
    end,
  },

  -- Signature peek
  "ray-x/lsp_signature.nvim",

  -- Indentation colors
  "lukas-reineke/indent-blankline.nvim",

  -- COPILOT
  { "github/copilot.vim" },

  -- Git integration
  {
    'lewis6991/gitsigns.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
  },

  -- Status line
  "hoob3rt/lualine.nvim",

  -- Colors
  "ellisonleao/gruvbox.nvim",
  { 'luisiacc/gruvbox-baby', branch = 'main' },
  "xiyaowong/nvim-transparent",

  -- Move lines easily
  "echasnovski/mini.move",

  -- File browser
  {
    'kyazdani42/nvim-tree.lua',
    dependencies = 'nvim-tree/nvim-web-devicons',
  },

  -- C-n multiple selection cursor
  "mg979/vim-visual-multi",

  -- Commenting
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
  },

  -- Colorise
  "norcalli/nvim-colorizer.lua",
  "brenoprata10/nvim-highlight-colors",
  "HiPhish/rainbow-delimiters.nvim",

  -- Show troubles in top right corner
  "ivanjermakov/troublesum.nvim",

  -- Autopairing
  {
    'altermo/ultimate-autopair.nvim',
    event = { 'InsertEnter', 'CmdlineEnter' },
    branch = 'v0.6',
    opts = {
    },
  },

  -- Add automatic "end"
  "RRethy/nvim-treesitter-endwise",
})
