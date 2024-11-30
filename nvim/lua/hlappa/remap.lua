-- Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})

-- Gitsigns
vim.keymap.set('n', '<leader>gs', ':Gitsigns blame_line<CR>')

-- File Explorer
vim.api.nvim_set_keymap('n', '<Leader>r', ':NvimTreeRefresh<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>n', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- splitting
vim.api.nvim_set_keymap('n', '<Leader>s', ':sp<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>v', ':vs<CR>', { noremap = true, silent = true })

-- Save and go back to insert mode
vim.api.nvim_set_keymap('i', 'jj', "<Esc>:w<CR>a", {})

-- Go to normal mode
vim.api.nvim_set_keymap('i', 'jk', "<Esc>", {})

-- Copilot
vim.api.nvim_set_keymap("i", "<C-j>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
vim.api.nvim_set_keymap("i", "<C-h>", 'copilot#Previous()', { silent = true, expr = true })
vim.api.nvim_set_keymap("i", "<C-l>", 'copilot#Next()', { silent = true, expr = true })

-- Trouble
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics<cr>", { silent = true, noremap = true })

-- Rename inc
vim.keymap.set("n", "<leader>rn", function()
  return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true })
