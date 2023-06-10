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
  { 'nvim-telescope/telescope.nvim',   dependencies = { 'nvim-lua/plenary.nvim' } },
  { 'nvim-treesitter/nvim-treesitter', cmd = 'TSUpdate' },
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
  {
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("trouble").setup {}
    end
  },
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
    end,
  },
  "ray-x/lsp_signature.nvim",
  "lukas-reineke/indent-blankline.nvim",
  { "github/copilot.vim" },
  {
    'lewis6991/gitsigns.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
  },
  "hoob3rt/lualine.nvim",
  "ellisonleao/gruvbox.nvim",
  { 'luisiacc/gruvbox-baby', branch = 'main' },
  "xiyaowong/nvim-transparent",
  "windwp/nvim-autopairs",
  "echasnovski/mini.move",
  {
    'kyazdani42/nvim-tree.lua',
    dependencies = 'nvim-tree/nvim-web-devicons',
  },
  "mg979/vim-visual-multi",
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
  },
  "norcalli/nvim-colorizer.lua",
  "andweeb/presence.nvim",
  "brenoprata10/nvim-highlight-colors"
})
