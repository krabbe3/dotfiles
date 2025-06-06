return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
    },

    -- configuration
    config = function()
        -- define aliases
        local builtin = require('telescope.builtin')

        -- setup telescope
        require('telescope').setup {
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
                        -- <leader>l opens file and centers cursor
                        ["<leader>l"] = function(prompt_bufnr)
                            require('telescope.actions').select_default(prompt_bufnr)
                            vim.cmd("normal! zz")
                        end,
                    },
                },
            },
            pickers = {
                find_files = {
                    -- theme = "ivy",
                    hidden = true,
                },
            },
            extensions = {
                fzf = {}
            }
        }

        require('telescope').load_extension('fzf')

        -- telescope keymaps
        -- telescope namespace is <leader>f(ind)
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<leader>fg', builtin.git_files, {})
        vim.keymap.set('n', '<leader>fs', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end)
    end
}
