return {
    "iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end,
    cmd = { "MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewStop" },
    ft = { "markdown" },
    config = function()
        vim.g.mkdp_auto_start = 0      -- Do not auto-start preview
        vim.g.mkdp_auto_close = 1     -- Auto-close preview on buffer leave
        vim.g.mkdp_echo_preview_url = 1 -- Echo preview URL in Neovim command line
    end,
}
