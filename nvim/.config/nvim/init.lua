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
    -- load packer
    local packer_loaded = pcall(require, 'packer.packer')
    if not packer_loaded then
        print('Packer could not be loaded')
    end

    -- oil file explorer
    --require("oil").setup()

    -- load keymaps
    local config_included = pcall(require, 'user.keymaps')
    if not config_included then
        print('Keymaps could not be included')
    end

    -- load options
    local config_included = pcall(require, 'user.options')
    if not config_included then
        print('Options could not be included')
    end
end

