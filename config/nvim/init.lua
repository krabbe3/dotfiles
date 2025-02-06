-- NEOVIM INITIALIZATION FILE!
-- include keymaps
local config_included = pcall(require, 'user.keymaps')
if not config_included then
	print('Keymaps could not be included')
end

-- include user defined options
local config_included = pcall(require, 'user.options')
if not config_included then
	print('Keymaps could not be included')
end
