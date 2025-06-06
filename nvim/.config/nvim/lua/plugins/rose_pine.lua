return {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
        require("rose-pine").setup({
            variant = "auto",
            dark_variant = "main",
            dim_inactive_windows = false,
            extend_background_behind_borders = true,

            enable = {
                terminal = true,
                legacy_highlights = true,
                migrations = true,
            },

            styles = {
                bold = true,
                -- italic text flag
                italic = false,
                transparency = false,
            }
        })
        -- set colorscheme after setup
        vim.cmd("colorscheme rose-pine")
        -- highlight color
        -- gold
        vim.api.nvim_set_hl(0, "Visual", { bg = "#f6c177" })
        -- purple smurple
        -- vim.api.nvim_set_hl(0, "Visual", { bg = "#8811bf" })
    end
}
