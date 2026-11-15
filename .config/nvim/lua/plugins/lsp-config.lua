return {
  "neovim/nvim-lspconfig",
  config = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    local lspconfig = require("lspconfig")

    -- Emmet
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

    -- Lua
    lspconfig.lua_ls.setup({
      capabilities = capabilities
    })

    -- TypeScript (NEW: use ts_ls instead of deprecated tsserver)
    lspconfig.ts_ls.setup({
      capabilities = capabilities
    })

    -- HTML
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

    -- CSS
    lspconfig.cssls.setup({
      capabilities = capabilities
    })

    -- Python
    lspconfig.pyright.setup({
      capabilities = capabilities,
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "basic",
            autoSearchPaths = true,
            useLibraryCodeForTypes = true
          }
        }
      }
    })

    -- Rust
    lspconfig.rust_analyzer.setup({
      capabilities = capabilities,
      settings = {
        ["rust-analyzer"] = {
          cargo = { allFeatures = true },
          checkOnSave = {
            command = "clippy"
          }
        }
      }
    })
  end
}

