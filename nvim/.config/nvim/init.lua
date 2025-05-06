-- NEOVIM INITIALIZATION FILE!
-- load lazy
local lazy_loaded = pcall(require, 'config.lazy')
if not lazy_loaded then
    print('Lazy could not be loaded')
end

-- load keymaps
local config_included = pcall(require, 'user.keymaps')
if not config_included then
    print('Keymaps could not be included')
end

-- load options
local options_included = pcall(require, 'user.options')
if not options_included then
    print('Options could not be included')
end


-- format .py files on save using black formatter
-- TBC

-- BLINK.CMP
-- blink-cmp Documentation active item color change for visibility
vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpActiveParameter", {
    fg = "#000000", -- black fg
    bg = "#f6c177", -- gold bg
})
