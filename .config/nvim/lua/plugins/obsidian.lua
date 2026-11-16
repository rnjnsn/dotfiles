-- obsidian.nvim: work on the ~/notes vault from Neovim.
-- Follow [[links]] (Enter or gf), see backlinks, open today's journal note,
-- insert templates, and complete [[links]] as you type.
-- Settings below match the Obsidian app (.obsidian/app.json, daily-notes.json).
return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  lazy = true,
  -- Load only for markdown files inside the vault, or when :Obsidian is run.
  event = {
    "BufReadPre " .. vim.fn.expand("~") .. "/notes/*.md",
    "BufNewFile " .. vim.fn.expand("~") .. "/notes/*.md",
  },
  cmd = "Obsidian",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>oo", "<cmd>Obsidian quick_switch<CR>", desc = "Obsidian: find note" },
    { "<leader>os", "<cmd>Obsidian search<CR>", desc = "Obsidian: search vault" },
    { "<leader>ob", "<cmd>Obsidian backlinks<CR>", desc = "Obsidian: backlinks" },
    { "<leader>ol", "<cmd>Obsidian links<CR>", desc = "Obsidian: links in note" },
    { "<leader>ot", "<cmd>Obsidian today<CR>", desc = "Obsidian: today's journal" },
    { "<leader>oy", "<cmd>Obsidian yesterday<CR>", desc = "Obsidian: yesterday's journal" },
    { "<leader>on", "<cmd>Obsidian new<CR>", desc = "Obsidian: new note (00_inbox)" },
    { "<leader>oT", "<cmd>Obsidian template<CR>", desc = "Obsidian: insert template" },
    { "<leader>or", "<cmd>Obsidian rename<CR>", desc = "Obsidian: rename note + update links" },
    { "<leader>oa", "<cmd>Obsidian open<CR>", desc = "Obsidian: open in the app" },
  },
  opts = {
    legacy_commands = false,
    workspaces = { { name = "notes", path = "~/notes" } },

    -- Same as the app: new notes go to 00_inbox, named by their title.
    new_notes_location = "notes_subdir",
    notes_subdir = "00_inbox",
    note_id_func = function(title)
      return title or tostring(os.time())
    end,

    -- Never add or rewrite id/aliases/tags frontmatter in existing notes.
    frontmatter = { enabled = false },

    daily_notes = {
      folder = "60_life/journal",
      date_format = "YYYY-MM/YYYYMMDD", -- e.g. 60_life/journal/2026-11/20261116.md
      default_tags = {},
      workdays_only = false,
    },
    templates = { folder = "90_system/templates" },
    attachments = { folder = "90_system/attachments" },

    -- [[link completion comes from the plugin's built-in LSP (shows in nvim-cmp).
    picker = { name = "telescope.nvim" },

    -- Enter toggles existing checkboxes only; it never turns a plain line into one.
    checkbox = { create_new = false },

    -- vim-pandoc already handles markdown display; don't add a second layer.
    ui = { enable = false },
  },
}
