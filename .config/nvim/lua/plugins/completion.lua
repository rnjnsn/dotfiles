return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lsp",
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- Load VSCode-style snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    -- HTML snippets
    local html_snippets = {
      luasnip.snippet({ trig = "fn", name = "footnote html" }, {
        luasnip.text_node('<sup class="footnote-ref" id="fnref:x"><a href="#fn:x">x</a></sup>'),
      }),
      luasnip.snippet({ trig = "fns", name = "footnotes section html" }, {
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
      luasnip.snippet({ trig = "ct", name = "citation html" }, {
        luasnip.text_node("(Smith 2023, 45)"),
      }),
    }

    -- Markdown snippets
    local markdown_snippets = {
      luasnip.snippet({ trig = "fn", name = "footnote markdown" }, {
        luasnip.text_node("{{% footnote %}}"),
      }),
      luasnip.snippet({ trig = "fns", name = "footnotes section markdown" }, {
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
      luasnip.snippet({ trig = "ct", name = "citation markdown" }, {
        luasnip.text_node("(Smith 2023, 45)"),
      }),
    }

    -- Obsidian-specific snippets
    local obsidian_snippets = {
      luasnip.snippet({ trig = "zn", name = "zettel note" }, {
        luasnip.text_node("- [["),
        luasnip.insert_node(1),
        luasnip.text_node("]]"),
      }),
    }

    local function create_znr_snippet()
      local zettel_dir = vim.fn.expand("~/notes")
      local cmd = string.format('fd -e md -t f . "%s" --print0 | xargs -0 ls -t | sed -n "2p"', zettel_dir)
      local handle = io.popen(cmd)
      local recent_file = handle:read("*a"):gsub("\n", "")
      handle:close()
      if recent_file == "" then return nil end
      local file = io.open(recent_file, "r")
      if not file then return nil end
      local content = file:read("*all")
      file:close()

      local backlinks = {}
      for line in content:gmatch("[^\r\n]+") do
        for link in line:gmatch("[^!]%[%[([^%]]+)%]%]") do
          table.insert(backlinks, "[[" .. link .. "]]")
        end
        local start_link = line:match("^%[%[([^%]]+)%]%]")
        if start_link then
          table.insert(backlinks, "[[" .. start_link .. "]]")
        end
      end

      local seen = {}
      local unique_backlinks = {}
      for _, link in ipairs(backlinks) do
        if not seen[link] then
          seen[link] = true
          table.insert(unique_backlinks, link)
        end
      end
      backlinks = unique_backlinks

      if #backlinks == 0 then return nil end
      local formatted_links = {}
      for _, backlink in ipairs(backlinks) do
        table.insert(formatted_links, "- " .. backlink)
      end
      local all_links = table.concat(formatted_links, "\n")
      return all_links, #backlinks, vim.fn.fnamemodify(recent_file, ":t")
    end

    local function add_znr_snippet()
      local znr_snippet = luasnip.snippet({
        trig = "znr",
        name = "zettel note recent",
        dscr = "Insert all backlinks from most recent note",
      }, {
        luasnip.function_node(function()
          local links, count, filename = create_znr_snippet()
          if links then
            vim.defer_fn(function()
              print("Loaded " .. count .. " backlinks from " .. filename)
            end, 100)
            return vim.split(links, "\n")
          else
            return { "- No recent backlinks found - " }
          end
        end),
        luasnip.insert_node(1),
      })

      table.insert(obsidian_snippets, znr_snippet)
    end

    add_znr_snippet()

    vim.api.nvim_create_user_command("ZnrRefresh", function()
      vim.cmd("source " .. vim.fn.stdpath("config") .. "/lua/plugins/completion.lua")
      print("znr snippet refreshed")
    end, { desc = "Refresh znr snippet with latest backlinks" })

    -- Extend pandoc filetype to use markdown snippets
    luasnip.filetype_extend("pandoc", { "markdown" })

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

