return {
    "neovim/nvim-lspconfig",
    config = function()
        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        
        local lspconfig = require("lspconfig")
        
        lspconfig.emmet_ls.setup({
            capabilities = capabilities,
            filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "templ" },
            init_options = {
                html = {
                    options = {
                        ["bem.enabled"] = true,
                    },
                },
            }
        })

        lspconfig.lua_ls.setup({
            capabilities = capabilities
        })
        lspconfig.ts_ls.setup({
            capabilities = capabilities
        })
        lspconfig.html.setup({
            capabilities = capabilities,
            filetypes = { "html", "templ" },
            init_options = {
                configurationSection = { "html", "css", "javascript" },
                embeddedLanguages = {
                    css = true,
                    javascript = true
                },
                provideFormatter = true,
                snippetSupport = true
            }
        })
        lspconfig.cssls.setup({
            capabilities = capabilities
        })
        lspconfig.pyright.setup({
            capabilities = capabilities,
            settings = {
                python = {
                    analysis = {
                        typeCheckingMode = "off",
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true
                    }
                }
            }
        })
        
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
    end
}
