return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "rcarriga/nvim-dap-ui",
            "mfussenegger/nvim-dap-python",
            'theHamsta/nvim-dap-virtual-text'
        },
        -- configuration
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")


            -- register debugpy adapter (debugpy sits under ~/.virtualenvs/)
            local python_path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
            require("dap-python").setup(python_path)

            -- use virtual texts
            require("nvim-dap-virtual-text").setup({})

            -- DAP UI
            -- setup
            dapui.setup()
            -- DAP UI connection to DAP
            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end

            -- DAP Keymaps
            -- breakpoint stuff
            vim.keymap.set('n', '<leader>dbt', function()
                dap.toggle_breakpoint()
            end, { desc = "toggle breakpoint" })
            vim.keymap.set('n', '<leader>dbc', function()
                dap.clear_breakpoints()
            end, { desc = "clear all breakpoints" })
            -- start continue restart kill
            vim.keymap.set('n', '<leader>dc', function()
                dap.continue()
            end, { desc = "continue" })
            vim.keymap.set('n', '<leader>dr', function()
                dap.restart()
            end, { desc = "restart debugging session" })
            vim.keymap.set("n", "<leader>dk", function()
                dap.terminate()
                dapui.close()
            end, { desc = "kill debugging" })
            -- step in over out vim logic (l, j, h)
            vim.keymap.set('n', '<leader>dl', function()
                dap.step_into()
            end, { desc = "step into" })
            vim.keymap.set('n', '<leader>dj', function()
                dap.step_over()
            end, { desc = "step over" })
            vim.keymap.set('n', '<leader>dh', function()
                dap.step_out()
            end, { desc = "step out" })
            -- hover variable under cursor
            vim.keymap.set("n", "<leader>d?", function()
                dapui.eval(nil, { enter = true })
            end, { desc = "hover variable under cursor during debugging" })
            -- close floating window under cursor
            vim.keymap.set("n", "<leader>jk", function()
                local win_config = vim.api.nvim_win_get_config(0)
                if win_config.relative ~= "" then -- Check if we're in a floating window
                    vim.cmd("close")              -- Close the window
                end
            end, { desc = "Close floating window with <leader>jk" })

            -- vim.keymap.set('n', '<leader>dh', function()
            --     require('dap.ui.widgets').hover()
            -- end, { desc = "hover" })
            -- vim.keymap.set('n', '<Leader>lp',
            --     function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
            -- vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
            -- vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
            -- vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function()
            --     require('dap.ui.widgets').hover()
            -- end)
            -- vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function()
            --     require('dap.ui.widgets').preview()
            -- end)
            -- vim.keymap.set('n', '<Leader>df', function()
            --     local widgets = require('dap.ui.widgets')
            --     widgets.centered_float(widgets.frames)
            -- end)
            -- vim.keymap.set('n', '<Leader>ds', function()
            --     local widgets = require('dap.ui.widgets')
            --     widgets.centered_float(widgets.scopes)
            -- end)
        end,
    }
}
