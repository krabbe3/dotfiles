-- telescoper remaps
local builtin = require('telescope.builtin')

-- file finder picker remaps
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)

-- navigation in file finder


require('telescope').setup{
    defaults = {
        file_ignore_patterns = {
            '.git/',
        },
        mappings = {
            i = {
                ["<C-j>"] = require('telescope.actions').move_selection_next,
                ["<C-k>"] = require('telescope.actions').move_selection_previous,
                ["<leader>jk"] = require('telescope.actions').close,
            },
            n = {
                ["<leader>jk"] = require('telescope.actions').close,
            },
        },
    },
    pickers = {
        find_files = {
            hidden = true,
        }
    }
}
