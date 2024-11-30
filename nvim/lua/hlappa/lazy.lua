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
  "onsails/lspkind.nvim",

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
  -- { "github/copilot.vim" },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = {
      show_help = "yes",         -- Show help text for CopilotChatInPlace, default: yes
      debug = false,             -- Enable or disable debug mode, the log file will be in ~/.local/state/nvim/CopilotChat.nvim.log
      disable_extra_info = 'no', -- Disable extra information (e.g: system prompt) in the response.
      language =
      "English"                  -- Copilot answer language settings when using default prompts. Default language is English.
      -- proxy = "socks5://127.0.0.1:3000", -- Proxies requests via https or socks.
      -- temperature = 0.1,
    },
    build = function()
      vim.notify("Please update the remote plugins by running ':UpdateRemotePlugins', then restart Neovim.")
    end,
    event = "VeryLazy",
    keys = {
      { "<leader>ccb", "<cmd>CopilotChatBuffer<cr>",  desc = "CopilotChat - Chat with current buffer" },
      { "<leader>cce", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
      { "<leader>ccT", "<cmd>CopilotChatTests<cr>",   desc = "CopilotChat - Generate tests" },
      {
        "<leader>cct",
        "<cmd>CopilotChatVsplitToggle<cr>",
        desc = "CopilotChat - Toggle Vsplit", -- Toggle vertical split
      },
      {
        "<leader>ccv",
        ":CopilotChatVisual ",
        mode = "x",
        desc = "CopilotChat - Open in vertical split",
      },
      {
        "<leader>ccp",
        ":CopilotChatInPlace<cr>",
        mode = "x",
        desc = "CopilotChat - Run in-place code",
      },
      {
        "<leader>ccf",
        "<cmd>CopilotChatFixDiagnostic<cr>", -- Get a fix for the diagnostic message under the cursor.
        desc = "CopilotChat - Fix diagnostic",
      },
      {
        "<leader>ccr",
        "<cmd>CopilotChatReset<cr>", -- Reset chat history and clear buffer.
        desc = "CopilotChat - Reset chat history and clear buffer",
      }
    },
  },

  -- Hover diagnostics
  "soulis-1256/eagle.nvim",

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

  -- Markdown
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  -- HTTP requests
  'BlackLight/nvim-http',

  -- Add automatic "end"
  "RRethy/nvim-treesitter-endwise",

  -- HTTP Client
  -- {
  --   "rest-nvim/rest.nvim",
  --   dependencies = { "nvim-neotest/nvim-nio" },
  -- },
})
