return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      local ls = require("luasnip")
      
      -- Add markdown snippets
      ls.add_snippets("markdown", {
        -- For just a footnote
        ls.snippet("fn", {
          ls.text_node({"{{< footnote ", "}}"}),
        }),
        
        -- For just a citation
        ls.snippet("ct", {
          ls.text_node("(Smith 2023, 45)"),
        }),
        
        -- For the footnotes section at bottom of document
        ls.snippet("fns", {
          ls.text_node({
            "",
            "{{< footnotes >}}",
            "{{< footnote-entry 1 >}}",
            "Your footnote explanation here.",
            "{{< /footnote-entry >}}",
            "{{< /footnotes >}}",
            "",
          }),
        }),
        
        -- For the references section
        ls.snippet("refs", {
          ls.text_node({
            "",
            "## References",
            "",
            "Smith, John. 2023. *Book Title*. Publisher.",
            "",
          }),
        }),
      })

      -- Set up nvim-cmp to show snippets
      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          expand = function(args)
            ls.lsp_expand(args.body)
          end,
        },
        sources = cmp.config.sources({
          { name = 'luasnip' },
          { name = 'nvim_lsp' },
        }),
        mapping = cmp.mapping.preset.insert({
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
      })
    end,
  }
}
