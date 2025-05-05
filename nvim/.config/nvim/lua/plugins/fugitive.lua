return{
    {
        "tpope/vim-fugitive",
        config = function()
            -- local variables
            local buffnr = vim.api.nvim_get_current_buf()
            local opts = {buffer = buffnr, remap = false}
            -- git status
            vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git Status (Fugitive)" })
            -- git blame
            vim.keymap.set("n", "<leader>gb", function()
                vim.cmd.Git('blame')
            end, opts, { desc = "Git blame (Fugitive)" })
            -- commit
            vim.keymap.set("n", "<leader>gc", function()
                vim.cmd.Git('commit')
            end, { buffer = buffnr, remap = false, desc = "Git commit (Fugitive)" })
            -- pull + rebase
            vim.keymap.set("n", "<leader>gp", function()
                vim.cmd.Git({"pull", "--rebase"})
            end, opts, { desc = "Git pull rebase (Fugitive)" })
            -- push
            vim.keymap.set("n", "<leader>gP", function()
                vim.cmd.Git("push")
            end, opts, { desc = "Git push (Fugitive)" })
        end,
    }
}
