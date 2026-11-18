-- nvim-treesitter `main` branch (the old `master` branch is frozen and
-- crashes on nvim 0.12). Needs the `tree-sitter` CLI to install parsers.
local langs = {
  "c", "lua", "vim", "vimdoc", "query",
  "elixir", "heex", "javascript", "html",
  "markdown", "markdown_inline",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install(langs)

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if not lang or not vim.treesitter.language.add(lang) then return end
        vim.treesitter.start(args.buf, lang)
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
