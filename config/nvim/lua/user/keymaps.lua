-- keymaps for my nvim setup
local opts = {noremap = true, silent = true}

-- define local keymap function for conciseness
local keymap = vim.keymap.set

-- INSERT mode keymaps
keymap('i', 'jk', '<ESC>', opts)

-- VISUAL mode keymaps
keymap('v', 'jk', '<ESC>', opts)
