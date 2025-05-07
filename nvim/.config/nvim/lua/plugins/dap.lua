return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "rcarriga/nvim-dap-ui",
            "mfussenegger/nvim-dap-python"
        },
        -- configuration
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")


            -- register debugpy adapter (debugpy sits under ~/.virtualenvs/)
            local python_path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
            require("dap-python").setup(python_path)

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
            vim.keymap.set('n', '<leader>dt', function()
                dap.toggle_breakpoint()
            end, { desc = "toggle breakpoint" })
            vim.keymap.set('n', '<leader>dc', function()
                dap.continue()
            end, { desc = "continue" })
            vim.keymap.set('n', '<leader>dso', function()
                dap.step_over()
            end, { desc = "step over" })
            vim.keymap.set('n', '<leader>dsi', function()
                dap.step_into()
            end, { desc = "step into" })
            vim.keymap.set('n', '<leader>dsO', function()
                dap.step_out()
            end, { desc = "step out" })
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
