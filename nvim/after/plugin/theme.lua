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

vim.cmd.colorscheme("gruvbox")

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


vim.cmd.highlight("IndentBlanklineIndent1 guibg=#1f1f1f gui=nocombine")
vim.cmd.highlight("IndentBlanklineIndent2 guibg=#1a1a1a gui=nocombine")
