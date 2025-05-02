-- configuration file for user defined neovim options
local opt = vim.opt

-- basic options
opt.shiftwidth = 4		        -- number of spaces for an indentation
opt.tabstop = 10			        -- 2 spaces for a tab
opt.softtabstop = 0		        -- softabs
opt.expandtab = true		    -- convert tabs to spaces
--opt.clipboard = "unnamedplus"

-- line numbers
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
-- true colors
vim.opt.termguicolors = true

-- status line
-- set statusline=%<%f\ %h%m%r%{FugitiveStatusline()}%=%-14.(%l,%c%V%)\ %P

