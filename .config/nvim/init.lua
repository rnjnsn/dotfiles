-- Basic settings
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "  -- Sets space as the leader key

-- Set up lazy.nvim loader
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
   vim.fn.system({
       "git",
       "clone",
       "--filter=blob:none",
       "https://github.com/folke/lazy.nvim.git",
       "--branch=stable",
       lazypath,
   })
end
vim.opt.rtp:prepend(lazypath)
require("vim-options")
require("lazy").setup("plugins")

-- Enable relative line numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- Prevent folding in markdown and pandoc files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "pandoc" },
  callback = function()
    vim.wo.foldenable = false
  end,
})

-- Define :Zet command to run the zet script and open the new note
vim.api.nvim_create_user_command("Zet", function()
  os.execute("zet")  -- Make sure 'zet' script is in your $PATH and executable
  local file = io.open("/tmp/last_zettel", "r")
  if file then
    local path = file:read("*l")
    file:close()
    if path and vim.fn.filereadable(path) == 1 then
      vim.cmd("edit " .. vim.fn.fnameescape(path))
    else
      print("Zet: Note file not found.")
    end
  else
    print("Zet: No recent note found.")
  end
end, {})

-- Map <leader>z (space + z) to run :Zet
vim.keymap.set("n", "<leader>z", ":Zet<CR>", { noremap = true, silent = true })

-- Writing mode setup
require('writing')

-- Footnotes in markdown: Ctrl-f (insert) new/toggle marker↔note, s hints,
-- Enter peek/jump, ]f [f, <leader>nf/nr/nc (see lua/footnotes.lua header)
require('footnotes')

-- :Export [pdf|docx] -> ~/docs/exports (pandoc defaults in ~/.local/share/pandoc)
require('export')

-- Commands
vim.api.nvim_create_user_command('Write', function()
  require('writing').setup()
end, { desc = 'Enter writing mode' })

vim.api.nvim_create_user_command('WriteToggle', function()
  require('writing').toggle()
end, { desc = 'Toggle writing mode' })
