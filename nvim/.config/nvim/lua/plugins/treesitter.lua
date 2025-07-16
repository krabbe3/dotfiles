return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ":TSUpdate",

        -- configuration
        config = function()
            require('nvim-treesitter.configs').setup({
                -- featured languages
                ensure_installed = { "vimdoc", "toml", "yaml", "c", "python", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "regex" },

                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                auto_install = true,

                -- treesitter highlighting
                highlight = {
                    enable = true,

                    -- disable function for large files (maybe)
                    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
                    -- disable = function(lang, buf)
                    -- local max_filesize = 100 * 1024 -- 100 KB
                    -- local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    -- if ok and stats and stats.size > max_filesize then
                    -- return true
                    -- end
                    -- end,

                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = false,
                },

                -- incremental selection and corresponding nvim keybindings
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn", -- set to `false` to disable one of the mappings
                        node_incremental = "grn",
                        scope_incremental = "grc",
                        node_decremental = "grm",
                    },
                }
            })
        end,

    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        config = function()
            require("treesitter-context").setup {
                -- Configuration options go here (all are optional)
                enable = true,        -- Enable this plugin (Can be enabled/disabled later via commands)
                max_lines = 0,        -- How many lines the window should span. 0 = no limit.
                line_numbers = true,
                trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
                mode = 'cursor',      -- Line used to calculate context. Options: 'cursor', 'topline'
                separator = '-',      -- Separator between context and content. Can be a string like "─"
                zindex = 20,          -- The Z-index of the context window
            }
        end
    }
}