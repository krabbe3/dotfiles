-- keymaps for my nvim setup
local opts = {noremap = true, silent = true}

-- define local keymap function for conciseness
local keymap = vim.keymap.set

-- define leader key
vim.g.mapleader = " "
vim.g.localmapleader = " "

-- NORMAL mode keymaps
keymap("n", "<leader>wh", "<C-w>h", opts, { desc = "Move to left split" })
keymap("n", "<leader>wj", "<C-w>j", opts, { desc = "Move to lower split" })
keymap("n", "<leader>wk", "<C-w>k", opts, { desc = "Move to upper split" })
keymap("n", "<leader>wl", "<C-w>l", opts, { desc = "Move to right split" })

-- INSERT mode keymaps
keymap('i', '<leader>jk', '<ESC>', opts, { desc = "Escape insert mode" })

-- VISUAL mode keymaps
keymap('v', '<leader>jk', '<ESC>', opts, { desc = "Escape visual mode" })
