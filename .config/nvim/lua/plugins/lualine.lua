return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "sainnhe/gruvbox-material", -- This exact repository
  },
  config = function()
    require('lualine').setup({
      options = {
        theme = 'gruvbox-material',
        icons_enabled = false, -- Disable icons
      },
      sections = {
        lualine_c = {
          { 'filename' },
          { function() return "Words: " .. vim.fn.wordcount().words end },
        }
      }
    })
  end
}

