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
o.autoread = true
o.listchars = { trail = '·', tab = '»»' }
o.list = true
o.encoding = "utf-8"
o.completeopt = "menu,menuone,noselect"
o.clipboard = "unnamedplus"
o.updatetime = 50
o.nu = true
o.relativenumber = true
o.softtabstop = 2
o.wrap = false
o.hlsearch = false
o.scrolloff = 8
o.signcolumn = "yes"

vim.g.mapleader = " "
