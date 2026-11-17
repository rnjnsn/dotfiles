return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "sainnhe/gruvbox-material", -- This exact repository
  },
  config = function()
    require('lualine').setup({
      options = {
        theme = 'gruvbox-material',
        icons_enabled = false,
      },
      sections = {
        lualine_c = {
          { 'filename' },
          -- markdown: words and characters (with spaces) without footnotes,
          -- frontmatter or markup; see lua/wordcount.lua
          { function() return require('wordcount').statusline() end },
        }
      }
    })
  end
}

