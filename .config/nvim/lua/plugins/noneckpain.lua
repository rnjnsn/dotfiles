return {
  "shortcuts/no-neck-pain.nvim",
  config = function()
    vim.keymap.set("n", "<leader>nn", ":NoNeckPain<CR>", { noremap = true, silent = true })

    require("no-neck-pain").setup({
    })
  end,
}
