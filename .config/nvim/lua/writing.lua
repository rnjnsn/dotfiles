local M = {}

M.setup = function()
  -- Enter zen mode
  require('zen-mode').toggle()
  
  -- Enable twilight (dims inactive text)
  require('twilight').enable()
  
  -- Spell check
  vim.opt_local.spell = true
  vim.opt_local.spelllang = 'en_us'
  
  -- Softwrap for prose
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
  vim.opt_local.breakindent = true
  
  -- Better navigation for wrapped lines
  vim.keymap.set('n', 'j', 'gj', { buffer = true, silent = true })
  vim.keymap.set('n', 'k', 'gk', { buffer = true, silent = true })
  vim.keymap.set('n', '0', 'g0', { buffer = true, silent = true })
  vim.keymap.set('n', '$', 'g$', { buffer = true, silent = true })
  
  print("✍️  Writing mode activated")
end

M.toggle = function()
  require('zen-mode').toggle()
  require('twilight').toggle()
end

return M
