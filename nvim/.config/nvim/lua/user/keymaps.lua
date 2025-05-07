-- keymaps for my nvim setup
local opts = { noremap = true, silent = true }

-- define local keymap function for conciseness
local keymap = vim.keymap.set

-- define leader key
vim.g.mapleader = " "
vim.g.localmapleader = " "

-- NORMAL mode keymaps
-- change pane in a window -> leader w
keymap("n", "<leader>wh", "<C-w>h", opts)
keymap("n", "<leader>wj", "<C-w>j", opts)
keymap("n", "<leader>wk", "<C-w>k", opts)
keymap("n", "<leader>wl", "<C-w>l", opts)
-- leader jk = esc in n
-- EXPERIMENTAL SEE IF THIS CAUSES PROBLEMS!!!!!!!!!!!!!!!!
keymap('n', '<leader>jk', '<ESC>', opts)

-- INSERT mode keymaps
keymap('i', 'jk', '<ESC>', opts)

-- VISUAL mode keymaps
keymap('v', '<leader>jk', '<ESC>', opts)
