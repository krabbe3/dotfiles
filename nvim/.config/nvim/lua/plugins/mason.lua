return {
    {
        "mason-org/mason.nvim",

        dependencies = {
            "mason-org/mason-lspconfig.nvim",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },

        -- config
        config = function()
            -- setup mason
            require("mason").setup({})

            -- setup mason lspconfig and install lsp servers!
            require("mason-lspconfig").setup({
                automatic_enable = false,
                ensure_installed = {
                    "lua_ls",
                    "pylsp",
                },
            })

            -- install other tools needed for the editor (black formatter, dap, ...)
            require("mason-tool-installer").setup({
                -- disable this, ohterwise we get a nil error due to some mapping function calls
                integrations = {
                    ['mason-lspconfig'] = false,
                    ['mason-null-ls'] = false,
                    ['mason-nvim-dap'] = false,
                },
                ensure_installed = {
                    "black",
                    "debugpy",
                },
            })
        end,
    },
}
