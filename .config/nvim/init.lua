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
-- Load plugins from the plugins directory
require("lazy").setup("plugins")

-- Enable relative line numbers
vim.wo.number = true
vim.wo.relativenumber = true

-- Map Cmd+A to select and copy all to the system clipboard (macOS)
vim.api.nvim_set_keymap('n', '<D-a>', 'ggVG"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<D-a>', '<Esc>ggVG"+y', { noremap = true, silent = true })

-- Alternatively, map Ctrl+A as a fallback
vim.api.nvim_set_keymap('n', '<C-a>', 'ggVG"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-a>', '<Esc>ggVG"+y', { noremap = true, silent = true })

