return {
  -- Writing mode plugins
  {
    'folke/zen-mode.nvim',
    opts = {
      window = {
        width = 90,
        options = {
          number = false,
          relativenumber = false,
          signcolumn = 'no',
          cursorline = false,
        }
      },
      plugins = {
        twilight = { enabled = true },
      }
    }
  },
  {
    'folke/twilight.nvim',
    opts = {
      dimming = {
        alpha = 0.25,
      },
      context = 10,
      -- Dim by paragraph, not treesitter node. The 'pandoc' filetype has no
      -- parser, and on nvim 0.12 twilight's treesitter check crashes :Write.
      treesitter = false,
    }
  },
}
