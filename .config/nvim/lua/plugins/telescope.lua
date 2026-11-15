return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      -- Keymaps
      vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
      vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

      -- 🔍 Custom: Find notes in ~/notes
      vim.keymap.set("n", "<leader>fn", function()
        builtin.find_files({
          prompt_title = "Find Notes",
          cwd = "~/notes",
        })
      end)

      -- Optional: grep inside notes
      vim.keymap.set("n", "<leader>gn", function()
        builtin.live_grep({
          prompt_title = "Grep Notes",
          cwd = "~/notes",
        })
      end)

      -- Setup
      telescope.setup({
        defaults = {
          mappings = {
            i = { ["<C-h>"] = "which_key" },
          },
        },
        pickers = {
          find_files = {
            find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })

      -- Load extensions
      telescope.load_extension("ui-select")
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- fzf-native must be separate with its own build
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  },
}
