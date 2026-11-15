return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",          -- ✅ Correct new name for TypeScript
          "html",
          "cssls",
          "pyright",
          "emmet_ls",
          "rust_analyzer"   -- ✅ Rust support
        }
      })
    end
  }
}

