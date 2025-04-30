-- keymaps for my nvim setup
local opts = {noremap = true, silent = true}

-- define local keymap function for conciseness
local keymap = vim.keymap.set

-- define leader key
vim.g.mapleader = " "

-- OIL KEYMAPS 
vim.keymap.set("n", "<leader>xp", vim.cmd.Oil, { desc = "Open Oil Filemanager" })

-- INSERT mode keymaps
keymap('i', 'jk', '<ESC>', opts)

-- VISUAL mode keymaps
keymap('v', '<leader>jk', '<ESC>', opts)
