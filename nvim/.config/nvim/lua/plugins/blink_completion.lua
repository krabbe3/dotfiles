return {
    {
        'saghen/blink.cmp',
        -- optional: provides snippets for the snippet source
        dependencies = { 'rafamadriz/friendly-snippets' },
        name = "blink-cmp",

        -- use a release tag to download pre-built binaries
        version = '*',

        -- config
        opts = {
            -- All presets have the following mappings:
            -- C-space: Open menu or open docs if already open
            -- C-n/C-p or Up/Down: Select next/previous item
            -- C-e: Hide menu
            -- C-k: Toggle signature help (if signature.enabled = true)
            -- See :h blink-cmp-config-keymap for defining your own keymap
            keymap = { preset = 'default' },

            appearance = {
                use_nvim_cmp_as_default = false,
                nerd_font_variant = 'mono',
            },

            -- (Default) Only show the documentation popup when manually triggered
            completion = {
                accept = { auto_brackets = { enabled = false }, },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 250,
                    update_delay_ms = 50,
                    treesitter_highlighting = true,
                    window = { border = "rounded" },
                }
            },
            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                --default = { 'lsp', 'path', 'snippets', 'buffer' },
                -- exclude buffer to prevent autocompletion always triggering
                -- TODO -> maybe make this interactive depending on file type
                default = { 'lsp', 'path', 'snippets' },
            },

            signature = {
                enabled = true,
                window = { border = "rounded" },
            },

            -- rust fuzzy matcher rust
            fuzzy = { implementation = "prefer_rust_with_warning" }
        },

        -- setup plugin with defined options
        config = function(_, opts)
            require('blink.cmp').setup(opts)

            -- documentation active item highlighting
            vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpActiveParameter",
                {
                    fg = "#000000", -- black fg
                    bg = "#f6c177", -- gold bg
                })
        end,
    },
}
