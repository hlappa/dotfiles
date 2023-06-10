-- Enable telescope theme
vim.g.gruvbox_baby_telescope_theme = 1

-- Enable transparent mode
vim.g.gruvbox_baby_transparent_mode = 1

vim.cmd.colorscheme("gruvbox-baby")

-- vim.cmd.colorscheme("gruvbox")

require("transparent").setup({
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
  exclude_groups = {}, -- table: groups you don't want to clear
})


vim.cmd.highlight("IndentBlanklineIndent1 guibg=#1f1f1f gui=nocombine")
vim.cmd.highlight("IndentBlanklineIndent2 guibg=#1a1a1a gui=nocombine")
