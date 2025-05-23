return {
    {
        "tpope/vim-fugitive",
        config = function()
            -- git status
            -- Keymaps
            -- namespace for fugitive is <leader>g(it)
            vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git Status (Fugitive)" })
        end,
    }
}
