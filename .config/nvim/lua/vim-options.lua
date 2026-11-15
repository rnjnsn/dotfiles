vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

vim.g.mapleader = " "  -- Sets space as the leader key

-- Markdown Preview mappings

vim.keymap.set("n", "<Space>mp", ":MarkdownPreview<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'B', ':silent !xdg-open "%"<CR>', { noremap = true, silent = true })

-- Substitute command mapping
vim.api.nvim_set_keymap("n", "S", ":%s//g<Left><Left>", { noremap = true, silent = false })

