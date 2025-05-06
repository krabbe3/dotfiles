-- configuration file for user defined neovim options
local opt = vim.opt
-- basic editor options
opt.shiftwidth = 4            -- number of spaces for an indentation
opt.tabstop = 10              -- number of spaces for a tab char
opt.softtabstop = 0           -- softabs
opt.smarttab = true           -- better tabs
opt.expandtab = true          -- convert tabs to spaces
-- system clipboard and yank buffer matching
opt.clipboard = "unnamedplus" -- system clipboard yanking pasting etc
-- true colors
opt.termguicolors = true

-- line numbers autocommands
-- Set relative line numbers in normal, visual, and select modes
opt.relativenumber = true
-- Use absolute line numbers in insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = "*",
    command = "set number relativenumber!"
})
-- Revert back to relative line numbers when leaving insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
    pattern = "*",
    command = "set relativenumber"
})

-- status line
-- set statusline=%<%f\ %h%m%r%{FugitiveStatusline()}%=%-14.(%l,%c%V%)\ %P
