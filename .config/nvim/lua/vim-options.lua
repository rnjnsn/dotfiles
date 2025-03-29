vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.g.mapleader = " "  -- Sets space as the leader key
vim.keymap.set("n", "<Space>mp", ":MarkdownPreview<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'b', ':silent !open -a "Google Chrome" "./%"<CR>', { noremap = true, silent = true })

-- Add clipboard mappings here
vim.keymap.set("n", "<leader>y", '"+y', { noremap = true })
vim.keymap.set("v", "<leader>y", '"+y', { noremap = true })
vim.keymap.set("n", "<leader>p", '"+p', { noremap = true })
vim.keymap.set("n", "<leader>P", '"+P', { noremap = true })

-- Substitute command mapping
vim.api.nvim_set_keymap("n", "S", ":%s//g<Left><Left>", { noremap = true, silent = false })

