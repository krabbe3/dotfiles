return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            local ts = require("nvim-treesitter")

            -- c, lua, vim, vimdoc, query, markdown, markdown_inline ship with Neovim
            ts.install({ "toml", "yaml", "python", "regex", "bash", "latex", "dockerfile" })

            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    local lang = vim.treesitter.language.get_lang(args.match)
                    if not lang then return end

                    -- replaces auto_install = true
                    if not vim.tbl_contains(ts.get_installed(), lang)
                        and vim.tbl_contains(ts.get_available(), lang) then
                        ts.install(lang)
                        return
                    end

                    -- replaces highlight = { enable = true }
                    if pcall(vim.treesitter.start, args.buf) then
                        -- optional: treesitter folds and indent
                        -- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                        -- vim.wo.foldmethod = "expr"
                        -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        opts = {
            enable = true,
            max_lines = 0,
            line_numbers = true,
            trim_scope = "outer",
            mode = "cursor",
            separator = "-",
            zindex = 20,
        },
    }
}