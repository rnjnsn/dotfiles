return {
  "sainnhe/gruvbox-material",
  priority = 1000,
  config = function()
    -- Set background to dark or light
    vim.o.background = "dark" -- or "light" for light mode

    -- Configure Gruvbox Material settings
    vim.g.gruvbox_material_background = "medium" -- Options: 'hard', 'medium', 'soft'
    vim.g.gruvbox_material_enable_italic = 1     -- Enable italics
    vim.g.gruvbox_material_better_performance = 1 -- Optimize for better performance

    -- Apply the colorscheme
    vim.cmd("colorscheme gruvbox-material")
  end,
}

