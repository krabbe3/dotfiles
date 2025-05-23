return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup()

            -- keymaps
            -- namespace for harpoon is <leader>t(rident) !!!
            -- add current file to harpoon list
            vim.keymap.set("n", "<leader>ta", function() harpoon:list():add() end)
            -- remove current file
            vim.keymap.set("n", "<leader>tr", function() harpoon:list():remove() end)
            -- open harpoon list
            vim.keymap.set("n", "<leader>to", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
            -- select 1,2,3,4 th file
            vim.keymap.set("n", "<leader>th", function() harpoon:list():select(1) end)
            vim.keymap.set("n", "<leader>tj", function() harpoon:list():select(2) end)
            vim.keymap.set("n", "<leader>tk", function() harpoon:list():select(3) end)
            vim.keymap.set("n", "<leader>tl", function() harpoon:list():select(4) end)
            -- select previous / next buffer within harpoon list
            vim.keymap.set("n", "<leader>tp", function() harpoon:list():prev() end)
            vim.keymap.set("n", "<leader>tn", function() harpoon:list():next() end)
        end,
    }
}
