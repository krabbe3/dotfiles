return {
    {
        'stevearc/oil.nvim',
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {},

        -- Optional dependencies
        -- dependencies = { { "echasnovski/mini.icons", opts = {} } },

        lazy = false,

        -- configuration
        config = function()
            require("oil").setup({
                -- Oil as default file explorer
                default_file_explorer = true,

                -- display settings
                columns = {
                    "icon",
                    -- "permissions",
                },

                -- save new file/dir before entering it
                prompt_save_on_select_new_entry = true,

                view_options = {
                    -- always show hidden files
                    show_hidden = true,
                    -- more convenient sorting of numbers in dirs (fast - only for small number of items, true, fals)
                    natural_order = "fast",
                    -- case insensitive sorting
                    case_insensitive = false,
               },

                -- preview window
                preview_win = {
                    update_on_cursor_moved = true,
                    preview_method = "fast_scratch", 
                },

                -- Keymaps
                keymaps = {
                    ["g?"] = { "actions.show_help", mode = "n" , desc = "Show default keymaps"},
                    ["<leader>p"] = { "actions.preview", opts = { horizontal = true, split = "botright"}, desc = "Show file preview" },
                    ["~"] = "<cmd>edit $HOME<CR>",
                    ["<leader>jk"] = { "actions.close", desc = "Close oil"},
                    ["<leader>h"] = { "actions.parent", desc = "Go parent dir"},
                    ["<leader>l"] = { "actions.select", desc = "Enter dir"},
                }
                    
            })
        end
    }
}
