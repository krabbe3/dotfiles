-- configuration file for user defined neovim options
local opt = vim.opt

-- indenting stuff
opt.shiftwidth = 4   -- number of spaces for an indentation
opt.tabstop = 4      -- number of spaces for a tab
opt.softtabstop = 4  -- softabs
opt.expandtab = true -- convert tabs to spaces
opt.smartindent = true

-- no wraps for long lines
opt.wrap = false

-- undotree settings for long changes
opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

-- merge vim yank buffer and system clipboard
-- sound not like a good idea according to primeagen and others
-- opt.clipboard = "unnamedplus" -- system clipboard yanking pasting etc

-- searching /
opt.hlsearch = false
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

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
-- true colors
opt.termguicolors = true

-- scrolloff
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.isfname:append("@-@")

-- update time
opt.updatetime = 50

-- colorcolumn
opt.colorcolumn = "80"

-- leader keys
vim.g.mapleader = " "
vim.g.localmapleader = " "

-- status line
-- vim.opt.statusline = "%<%f %h%m%r%{FugitiveStatusline()}%=%-14.(%l,%c%V%) %P"
