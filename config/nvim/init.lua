-- NEOVIM INITIALIZATION FILE!
-- VSCODE Neovim setup
if vim.g.vscode then
    local config_included = pcall(require, 'user.keymaps_vsc')
    if not config_included then
	    print('Keymaps could not be included')
    end

    local config_included = pcall(require, 'user.options_vsc')
    if not config_included then
	    print('Options could not be included')
    end

-- ordinary Neovim setup
else
    local config_included = pcall(require, 'user.keymaps')
    if not config_included then
	    print('Keymaps could not be included')
    end

    local config_included = pcall(require, 'user.options')
    if not config_included then
	    print('Options could not be included')
    end
end

