-- configuration file for user defined neovim options
local opt = vim.opt

-- basic options
opt.number = true		-- set nubmered lines
opt.relativenumber = true 	-- set relative numbers
opt.shiftwidth = 4		-- number of spaces for an indentation
opt.tabstop = 4			-- 2 spaces for a tab
opt.softtabstop = 0		-- softabs
opt.expandtab = true		-- convert tabs to spaces
opt.clipboard = "unnamedplus"
