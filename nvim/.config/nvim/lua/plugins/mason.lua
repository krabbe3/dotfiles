return {
    {
        "mason-org/mason.nvim",
        lazy = false,

        dependencies = { "mason-org/mason-lspconfig.nvim" },

        -- config
        config = function()
            -- setup mason
            require("mason").setup()

            -- setup mason lspconfig
            require("mason-lspconfig").setup({
                automatic_enable = false,
                ensure_installed = {
                    "lua_ls",
                    "pylsp",
                },
            })
        end,
    },
}
