return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- blink autocompletion
            "saghen/blink.cmp",
            -- folke lazydev for easy nvim
            {
                "folke/lazydev.nvim",
                ft = "lua", -- only load on lua files
                opts = {
                    library = {
                        -- See the configuration section for more details
                        -- Load luvit types when the `vim.uv` word is found
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                    },
                },
            },
        },
        config = function()
            -- SETUP DIFFERENT LANGUAGE SERVERS FOR DIFFERENT LANGUAGES
            --
            -- lua_ls with capabilities
            local capabilities = require('blink.cmp').get_lsp_capabilities()
            require("lspconfig").lua_ls.setup({
                capabilities = capabilities,
            })

            -- pylsp with capabilities
            require("lspconfig").pylsp.setup({
                capabilities = capabilities,
            })

            -- basedpyright for even better type hints
            require("lspconfig").basedpyright.setup({
                capabilities = capabilities
            })

            -- -- ruff lsp for python (lightning fast)
            -- require("lspconfig").ruff.setup({
            --     capabilities = capabilities,
            -- })

            -- KEYMAPS for LSPs
            -- LSP namespace is <leader>s(erver)
            -- change keymaps on attach
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    -- check for nil
                    if not client then return end

                    -- renaming variables
                    if client.supports_method('textDocument/rename') then
                        vim.keymap.set('n', '<leader>scn', vim.lsp.buf.rename,
                            { buffer = args.buf, desc = "change name" })
                    end

                    -- code action
                    if client.supports_method('textDocument/codeAction') then
                        vim.keymap.set('n', '<leader>sca',
                            vim.lsp.buf.code_action,
                            { buffer = args.buf, desc = "code action" })
                    end

                    -- references as quickfix list
                    if client.supports_method('textDocument/references') then
                        vim.keymap.set('n', '<leader>sfr', vim.lsp.buf
                            .references,
                            { buffer = args.buf, desc = "find references" })
                    end

                    -- go implementations
                    if client.supports_method('textDocument/implementation') then
                        vim.keymap.set('n', '<leader>sfi',
                            vim.lsp.buf.implementation,
                            { buffer = args.buf, desc = "find implementation" })
                    end

                    -- go definition and go back
                    if client.supports_method('textDocument/definition') then
                        vim.keymap.set('n', '<leader>sgd', vim.lsp.buf.definition,
                            { buffer = args.buf, desc = "go definition" })
                        vim.keymap.set('n', '<leader>sgb', ':normal! <C-o><CR>',
                            { buffer = args.buf, desc = "go back" })
                    end

                    -- hover definition
                    if client.supports_method('textDocument/hover') then
                        vim.keymap.set('n', '<leader>sh', vim.lsp.buf.hover,
                            { buffer = args.buf, desc = "hover definition" })
                    end

                    -- formatting, if supported -> all files
                    -- --> python uses black on save to sff is a way to preformat the files while coding
                    if client.supports_method('textDocument/formatting') then
                        -- remap format to leader ff for convenience
                        vim.keymap.set('n', '<leader>sff', function()
                            vim.lsp.buf.format()
                        end, { buffer = args.buf, desc = "format file" })

                        -- autocommand to format .lua files on save
                        if vim.bo.filetype == "lua" then
                            vim.api.nvim_create_autocmd('BufWritePre', {
                                buffer = args.buf,
                                callback = function()
                                    vim.lsp.buf.format({
                                        bufnr = args.buf,
                                        id =
                                            client.id
                                    })
                                end,
                            })
                        end
                    end
                end,
            })
        end,
    }
}
