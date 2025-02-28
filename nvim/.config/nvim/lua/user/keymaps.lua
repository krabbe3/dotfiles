-- keymaps for my nvim setup
local opts = {noremap = true, silent = true}

-- define local keymap function for conciseness
local keymap = vim.keymap.set

-- define leader key
vim.g.mapleader = " "

-- netrw keymaps
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- INSERT mode keymaps
keymap('i', 'jk', '<ESC>', opts)

-- VISUAL mode keymaps
keymap('v', 'jk', '<ESC>', opts)
