-- Composing mail (m / aerc)
vim.opt_local.textwidth = 72
vim.opt_local.formatoptions:append("w") -- format=flowed-friendly
vim.opt_local.spell = true
vim.opt_local.spelllang = { "en", "de" }
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.number = false
vim.opt_local.relativenumber = false
-- <leader>s : save & quit (send prompt follows), <leader>q : cancel
vim.keymap.set("n", "<leader>s", "<cmd>wq<cr>", { buffer = true, desc = "Send mail" })
vim.keymap.set("n", "<leader>q", "<cmd>cq<cr>", { buffer = true, desc = "Cancel mail" })
