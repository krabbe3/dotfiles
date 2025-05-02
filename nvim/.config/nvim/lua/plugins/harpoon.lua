return{
    {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup()

        -- keymaps
        -- add current file to harpoon list
        vim.keymap.set("n", "<leader>ah", function() harpoon:list():add() end)
        -- open harpoon list
        vim.keymap.set("n", "<leader>oh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
        -- select 1,2,3,4 th file
        vim.keymap.set("n", "<leader>h", function() harpoon:list():select(1) end)
        vim.keymap.set("n", "<leader>j", function() harpoon:list():select(2) end)
        vim.keymap.set("n", "<leader>k", function() harpoon:list():select(3) end)
        vim.keymap.set("n", "<leader>l", function() harpoon:list():select(4) end)
        -- select previous / next buffer within harpoon list
        vim.keymap.set("n", "<leader>ph", function() harpoon:list():prev() end)
        vim.keymap.set("n", "<leader>nh", function() harpoon:list():next() end)
    end,
    }
}
