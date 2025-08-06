return {
    {
        {
            "echasnovski/mini.icons",
            opts = {},
            lazy = true,
            specs = {
                { "nvim-tree/nvim-web-devicons", enabled = true, optional = true },
            },

            config = function()
                require("mini.icons").setup({
                    style = "glyph",
                })
            end,
        },
    }
}