return {
    {
        'stevearc/oil.nvim',
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {},

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

                vim.api.nvim_create_autocmd("User", {
                    pattern = "OilEnter",
                    callback = vim.schedule_wrap(function(args)
                        local oil = require("oil")
                        if vim.api.nvim_get_current_buf() == args.data.buf and oil.get_cursor_entry() then
                            oil.open_preview({
                                vertical = true,
                                split = "belowright",
                            })
                        end
                    end),
                }),

                -- Keymaps
                -- oil namespace is <leader>x(plorer)
                keymaps = {
                    ["<leader>x?"] = { "actions.show_help", mode = "n", desc = "Show default keymaps" },
                    ["<leader>xp"] = { "actions.preview", opts = { vertical = true, split = "botright" }, desc = "Show file preview" },
                    -- movements derived from basic vim movements
                    -- go to home dir
                    ["<leader>~"] = "<cmd>edit $HOME<CR>",
                    ["<leader>jk"] = { "actions.close", desc = "Close oil" },
                    ["<leader>h"] = { "actions.parent", desc = "Go parent dir" },
                    ["<leader>l"] = { "actions.select", desc = "Enter dir" },
                }

            })
            -- open oil with leader xp
            vim.keymap.set("n", "<leader>xp", vim.cmd.Oil, { desc = "Open Oil Filemanager" })
        end
    }
}