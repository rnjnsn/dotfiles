-- Pandoc/Obsidian footnote helpers for markdown buffers.
--   Alt-n  inline footnote ^[…] at the cursor (insert or normal mode)
--   Alt-l  labeled footnote [^N]: inserts the next number, adds "[^N]: " at the
--          end of the file and puts you there in insert mode
--   Alt-j  jump between a labeled footnote's marker and its text (Ctrl-o jumps back)
local M = {}

local function esc(s)
  return vim.fn.escape(s, [[\/.*$^~[]])
end

-- Highest numeric label in the buffer, plus one.
local function next_number(buf)
  local max = 0
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    for n in line:gmatch("%[%^(%d+)%]") do
      max = math.max(max, tonumber(n))
    end
  end
  return max + 1
end

function M.labeled(from_insert)
  local buf = 0
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  if not from_insert then
    local line = vim.api.nvim_get_current_line()
    col = math.min(col + 1, #line) -- insert after the cursor, like `a`
  end
  local n = next_number(buf)
  local marker = "[^" .. n .. "]"
  vim.api.nvim_buf_set_text(buf, row - 1, col, row - 1, col, { marker })

  -- remember where we were, so Ctrl-o / Alt-j bring you back
  vim.api.nvim_win_set_cursor(0, { row, col + #marker - 1 })
  vim.cmd("normal! m'")

  local last = vim.api.nvim_buf_line_count(buf)
  local last_line = vim.api.nvim_buf_get_lines(buf, last - 1, last, false)[1]
  local new = {}
  if last_line ~= "" and not last_line:match("^%[%^[^%]]+%]:") then
    table.insert(new, "")
  end
  table.insert(new, marker .. ": ")
  if last_line == "" then
    vim.api.nvim_buf_set_lines(buf, last - 1, last, false, new)
  else
    vim.api.nvim_buf_set_lines(buf, last, last, false, new)
  end
  local end_row = vim.api.nvim_buf_line_count(buf)
  vim.api.nvim_win_set_cursor(0, { end_row, #new[#new] })
  vim.cmd("startinsert!")
end

function M.jump()
  local line = vim.api.nvim_get_current_line()
  local cur = vim.api.nvim_win_get_cursor(0)[2] + 1

  -- on a definition line: go to the first marker in the text
  local def = line:match("^%[%^([^%]]+)%]:")
  if def then
    vim.cmd("normal! m'")
    local pos = vim.fn.searchpos([[\[\^]] .. esc(def) .. [[\]\(:\)\@!]], "nw")
    if pos[1] == 0 then return vim.notify("No marker for [^" .. def .. "]") end
    return vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] - 1 })
  end

  -- otherwise: the marker under the cursor, or the first one on the line
  local label
  local start = 1
  while true do
    local s, e, l = line:find("%[%^([^%]]+)%]", start)
    if not s then break end
    label = label or l
    if cur >= s and cur <= e then label = l break end
    start = e + 1
  end
  if not label then return vim.notify("No footnote marker on this line") end

  vim.cmd("normal! m'")
  local pos = vim.fn.searchpos([[^\[\^]] .. esc(label) .. [[\]:]], "nw")
  if pos[1] == 0 then return vim.notify("No text found for [^" .. label .. "]") end
  vim.api.nvim_win_set_cursor(0, { pos[1], #label + 4 })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "pandoc" },
  callback = function(ev)
    local o = { buffer = ev.buf, silent = true }
    vim.keymap.set("i", "<M-n>", "^[]<C-g>U<Left>", vim.tbl_extend("force", o, { desc = "Inline footnote" }))
    vim.keymap.set("n", "<M-n>", "a^[]<C-g>U<Left>", vim.tbl_extend("force", o, { desc = "Inline footnote" }))
    vim.keymap.set("i", "<M-l>", function() M.labeled(true) end, vim.tbl_extend("force", o, { desc = "Labeled footnote" }))
    vim.keymap.set("n", "<M-l>", function() M.labeled(false) end, vim.tbl_extend("force", o, { desc = "Labeled footnote" }))
    vim.keymap.set("n", "<M-j>", M.jump, vim.tbl_extend("force", o, { desc = "Footnote marker <-> text" }))
  end,
})

return M
