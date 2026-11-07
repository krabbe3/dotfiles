-- autocommand to format python files with black formatter on save (from Mason)
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { "*.py" },
    callback = function()
        local black_path = vim.fn.stdpath("data") .. "/mason/bin/black"
        local file_path = vim.fn.expand("%:p")

        if vim.fn.filereadable(black_path) == 1 then
            local output = vim.fn.system({ black_path, "-l", "79", file_path })

            if vim.v.shell_error == 0 then
                vim.cmd("checktime") -- Only reload if file was changed on disk
                vim.notify("Black formatted (post-save): " .. file_path, vim.log.levels.INFO)
            else
                vim.notify("Black error:\n" .. output, vim.log.levels.ERROR)
            end
        else
            vim.notify("Black not found at Mason path:\n" .. black_path, vim.log.levels.ERROR)
        end
    end,
    desc = "Applies Black Python formatting after saving",
})

-- reload buffers changed on disk by other programs (e.g. a dune agent editing
-- the same files); unsaved buffers get a warning instead of a silent reload.
-- Throttled to once per second because updatetime is low.
local last_checktime = 0
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermLeave" }, {
    callback = function()
        local now = vim.uv.now()
        if now - last_checktime < 1000 or vim.fn.getcmdwintype() ~= "" then
            return
        end
        last_checktime = now
        vim.cmd("checktime")
    end,
    desc = "Reload buffers changed outside nvim",
})
