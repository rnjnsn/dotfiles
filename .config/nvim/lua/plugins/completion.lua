return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lsp",
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    
    -- Load VSCode-style snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    -- HTML snippets
    local html_snippets = {
      luasnip.snippet({
        trig = "fn",
        name = "footnote html",
        dscr = "Add a footnote in HTML",
      }, {
        luasnip.text_node('<sup class="footnote-ref" id="fnref:x"><a href="#fn:x">x</a></sup>'),
      }),
      
      luasnip.snippet({
        trig = "fns",
        name = "footnotes section html",
      }, {
        luasnip.text_node({
          "",
          "{{< footnotes >}}",
          "{{< footnote-entry 1 >}}",
          "Your footnote explanation here.",
          "{{< /footnote-entry >}}",
          "{{< /footnotes >}}",
          "",
        }),
      }),
      
      luasnip.snippet({
        trig = "ct",
        name = "citation html",
      }, {
        luasnip.text_node("(Smith 2023, 45)"),
      }),
    }
    
    -- Markdown snippets
    local markdown_snippets = {
      luasnip.snippet({
        trig = "fn",
        name = "footnote markdown",
        dscr = "Add a footnote in Markdown",
      }, {
        luasnip.text_node("{{% footnote %}}"),
      }),
      
      luasnip.snippet({
        trig = "fns",
        name = "footnotes section markdown",
      }, {
        luasnip.text_node({
          "",
          "{{% footnotes %}}",
          "{{% footnote-entry 1 %}}",
          "Your footnote explanation here.",
          "{{% /footnote-entry %}}",
          "{{% /footnotes %}}",
          "",
        }),
      }),
      
      luasnip.snippet({
        trig = "ct",
        name = "citation markdown",
      }, {
        luasnip.text_node("(Smith 2023, 45)"),
      }),
    }
    
    -- Obsidian-specific snippets
    local obsidian_snippets = {
      luasnip.snippet({
        trig = "zn",
        name = "zettel note",
        dscr = "Create an Obsidian note link with bullet point",
      }, {
        luasnip.text_node("* [[Note]] - "),
        luasnip.insert_node(1),
      }),
    }
    
    -- Add snippets to their respective filetypes
    luasnip.add_snippets("html", html_snippets)
    luasnip.add_snippets("markdown", markdown_snippets)
    luasnip.add_snippets("markdown", obsidian_snippets)
    
    -- Set up nvim-cmp
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
      }, {
        { name = "buffer" },
      }),
    })
  end,
}
