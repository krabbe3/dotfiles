-- keymaps for my nvim setup
local opts = {noremap = true, silent = true}

-- define local keymap function for conciseness
local keymap = vim.keymap.set

-- INSERT mode keymaps
-- this is fully controlled by VSC :(

-- VISUAL mode keymaps
keymap('v', 'jk', '<ESC>', opts)
