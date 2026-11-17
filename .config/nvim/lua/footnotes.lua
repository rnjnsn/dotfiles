-- Footnote helpers for markdown buffers (pandoc/Obsidian syntax [^N] … [^N]: text).
-- No Alt keys: left Alt is keyd's navigation layer (Alt+hjkl = arrows).
--
--   s           hint layer: label every visible [^N] marker, type a label → pop-up
--   Enter       on a marker: pop-up with its note
--               on a note line ([^N]: …): back to its marker
--               anywhere else: Enter as before (obsidian.nvim links, checkboxes)
--   ]f / [f     next / previous marker
--   <leader>nf  new footnote: marker here, text line at the end, insert mode;
--               all numbers then follow their order in the text
--   Ctrl-f      insert mode toggle: on/right after a marker, jump to its note;
--               on a note line, back to the marker; elsewhere, new footnote
--               (when no completion docs are open)
--   <leader>nr  :FootnoteRenumber, numbers 1, 2, 3 … in reading order, texts sorted
--   <leader>nc  :FootnoteCheck, problems go to the quickfix list
--
-- In the pop-up: Enter edit the note (Ctrl-o back) · n / p next / previous footnote
--                s hint again · q / Esc close
-- Backup of the Alt-key version: footnotes.lua.bak-20261117
local M = {}
local api = vim.api

local ns = api.nvim_create_namespace("footnote_hints")
local HINT_KEYS = "asdfjklghqwertyuiopzxcvbnm"
api.nvim_set_hl(0, "FootnoteHint", { link = "IncSearch", default = true })

-- ── parsing ────────────────────────────────────────────────────────────────

-- Footnote references in one line: { {s=, e=, label=}, … } (1-based columns).
-- The "[^N]:" that starts a note line is not a reference.
local function refs_in_line(line)
  local out, start = {}, 1
  while true do
    local s, e, label = line:find("%[%^([^%]]+)%]", start)
    if not s then break end
    if not (s == 1 and line:sub(e + 1, e + 1) == ":") then
      table.insert(out, { s = s, e = e, label = label })
    end
    start = e + 1
  end
  return out
end

local function def_label(line)
  return line:match("^%[%^([^%]]+)%]:")
end

-- Every reference in the buffer, in reading order: { {row=, col=, label=}, … }
-- (row 1-based, col 0-based, as nvim_win_set_cursor wants them).
local function all_refs(buf)
  local out = {}
  for i, line in ipairs(api.nvim_buf_get_lines(buf, 0, -1, false)) do
    for _, r in ipairs(refs_in_line(line)) do
      table.insert(out, { row = i, col = r.s - 1, label = r.label })
    end
  end
  return out
end

-- Row (1-based) of the note for `label`, or nil.
local function def_row(lines, label)
  local prefix = "[^" .. label .. "]:"
  for i, line in ipairs(lines) do
    if line:sub(1, #prefix) == prefix then return i end
  end
end

-- The note's text: its first line plus continuation lines (indented paragraphs
-- after a blank line, or lines that directly follow it).
local function def_text(lines, row)
  local first = lines[row]:gsub("^%[%^[^%]]+%]:%s*", "")
  local out = { first }
  local i = row + 1
  while i <= #lines do
    local l = lines[i]
    if def_label(l) then break end
    if l == "" then
      local nxt = lines[i + 1]
      if not (nxt and nxt:match("^%s+%S")) then break end
      table.insert(out, "")
    else
      local stripped = l:gsub("^    ", ""):gsub("^\t", "")
      table.insert(out, stripped)
    end
    i = i + 1
  end
  return out
end

-- ── pop-up ─────────────────────────────────────────────────────────────────

local popup = nil -- { win=, src_win=, row=, col=, label=, has_def= }

function M.close()
  if not popup then return end
  local p = popup
  popup = nil
  if api.nvim_win_is_valid(p.win) then api.nvim_win_close(p.win, true) end
  if api.nvim_win_is_valid(p.src_win) then api.nvim_set_current_win(p.src_win) end
end

local function text_height(lines, width)
  local h = 0
  for _, l in ipairs(lines) do
    h = h + math.max(1, math.ceil(vim.fn.strdisplaywidth(l) / width))
  end
  return h
end

-- Show the note for the reference at (row, col) in the current window.
function M.peek(row, col, label)
  M.close()
  local src_win = api.nvim_get_current_win()
  local src_buf = api.nvim_win_get_buf(src_win)
  api.nvim_win_set_cursor(src_win, { row, col })

  local lines = api.nvim_buf_get_lines(src_buf, 0, -1, false)
  local drow = def_row(lines, label)
  local text = drow and def_text(lines, drow) or { "(no text for [^" .. label .. "]; see :FootnoteCheck)" }

  local width = math.min(80, vim.o.columns - 6)
  local height = math.min(15, text_height(text, width))
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf, 0, -1, false, text)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local win = api.nvim_open_win(buf, true, {
    relative = "cursor", row = 1, col = 0,
    width = width, height = height,
    style = "minimal", border = "rounded",
    title = " [^" .. label .. "] ", title_pos = "left",
    footer = " ⏎ edit · n/p next/prev · s hints · q close ", footer_pos = "right",
  })
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  popup = { win = win, src_win = src_win, row = row, col = col, label = label, has_def = drow ~= nil }

  local o = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set("n", "q", M.close, o)
  vim.keymap.set("n", "<Esc>", M.close, o)
  vim.keymap.set("n", "<CR>", M.edit, o)
  vim.keymap.set("n", "n", function() M.step(1) end, o)
  vim.keymap.set("n", "p", function() M.step(-1) end, o)
  vim.keymap.set("n", "s", function() M.close(); M.hint() end, o)
  api.nvim_create_autocmd("WinLeave", {
    buffer = buf, once = true,
    callback = function()
      vim.schedule(function()
        if popup and popup.win == win then M.close() end
      end)
    end,
  })
end

-- From the pop-up: go to the note to edit it. Ctrl-o returns to the marker.
function M.edit()
  if not popup then return end
  local p = popup
  M.close()
  if not p.has_def then return vim.notify("No text for [^" .. p.label .. "]") end
  vim.cmd("normal! m'")
  local lines = api.nvim_buf_get_lines(0, 0, -1, false)
  api.nvim_win_set_cursor(0, { def_row(lines, p.label), #p.label + 4 })
end

-- From the pop-up: show the next (dir=1) or previous (dir=-1) footnote.
function M.step(dir)
  if not popup then return end
  local p = popup
  M.close()
  local refs = all_refs(0)
  local pick
  if dir > 0 then
    for _, r in ipairs(refs) do
      if r.row > p.row or (r.row == p.row and r.col > p.col) then pick = r break end
    end
  else
    for i = #refs, 1, -1 do
      local r = refs[i]
      if r.row < p.row or (r.row == p.row and r.col < p.col) then pick = r break end
    end
  end
  if not pick then
    vim.notify(dir > 0 and "Last footnote" or "First footnote")
    return M.peek(p.row, p.col, p.label)
  end
  M.peek(pick.row, pick.col, pick.label)
end

-- ── hint layer ─────────────────────────────────────────────────────────────

local function make_labels(n)
  local keys, out = vim.split(HINT_KEYS, ""), {}
  if n <= #keys then
    for i = 1, n do out[i] = keys[i] end
    return out
  end
  for _, a in ipairs(keys) do
    for _, b in ipairs(keys) do
      table.insert(out, a .. b)
      if #out == n then return out end
    end
  end
  return out
end

function M.hint()
  local buf = api.nvim_get_current_buf()
  local top, bot = vim.fn.line("w0"), vim.fn.line("w$")
  local cur = api.nvim_win_get_cursor(0)[1]
  local targets = {}
  for i, line in ipairs(api.nvim_buf_get_lines(buf, top - 1, bot, false)) do
    for _, r in ipairs(refs_in_line(line)) do
      table.insert(targets, { row = top + i - 1, col = r.s - 1, label = r.label })
    end
  end
  if #targets == 0 then return vim.notify("No footnote markers on screen") end
  -- the marker nearest the cursor gets the easiest key
  table.sort(targets, function(a, b)
    local da, db = math.abs(a.row - cur), math.abs(b.row - cur)
    if da ~= db then return da < db end
    if a.row ~= b.row then return a.row < b.row end
    return a.col < b.col
  end)

  local labels = make_labels(#targets)
  for i, t in ipairs(targets) do
    t.hint = labels[i]
    api.nvim_buf_set_extmark(buf, ns, t.row - 1, t.col, {
      virt_text = { { t.hint, "FootnoteHint" } }, virt_text_pos = "overlay", priority = 1000,
    })
  end
  vim.cmd("redraw")

  local typed = ""
  while true do
    local ok, ch = pcall(vim.fn.getcharstr)
    if not ok or ch == "\27" then break end
    typed = typed .. ch
    local exact, prefix = nil, false
    for _, t in ipairs(targets) do
      if t.hint == typed then exact = t end
      if t.hint:sub(1, #typed) == typed then prefix = true end
    end
    if exact then
      api.nvim_buf_clear_namespace(buf, ns, 0, -1)
      return M.peek(exact.row, exact.col, exact.label)
    end
    if not prefix then break end
  end
  api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  vim.cmd("redraw")
end

-- ── Enter ──────────────────────────────────────────────────────────────────

local function on_wikilink(line, col)
  local start = 1
  while true do
    local s, e = line:find("%[%[.-%]%]", start)
    if not s then return false end
    if col >= s and col <= e then return true end
    start = e + 1
  end
end

-- expr mapping: returns the keys to run.
function M.enter()
  local line = api.nvim_get_current_line()
  local col = api.nvim_win_get_cursor(0)[2] + 1

  for _, r in ipairs(refs_in_line(line)) do
    if col >= r.s and col <= r.e then
      return "<Cmd>lua require('footnotes').peek_at_cursor()<CR>"
    end
  end
  if def_label(line) and not on_wikilink(line, col) then
    return "<Cmd>lua require('footnotes').back_to_ref()<CR>"
  end
  if vim.b.obsidian_buffer then
    local ok, actions = pcall(require, "obsidian.actions")
    if ok then return actions.smart_action() end
  end
  return "<CR>"
end

function M.peek_at_cursor()
  local row, c = unpack(api.nvim_win_get_cursor(0))
  for _, r in ipairs(refs_in_line(api.nvim_get_current_line())) do
    if c + 1 >= r.s and c + 1 <= r.e then return M.peek(row, r.s - 1, r.label) end
  end
end

function M.back_to_ref()
  local label = def_label(api.nvim_get_current_line())
  for _, r in ipairs(all_refs(0)) do
    if r.label == label then
      vim.cmd("normal! m'")
      return api.nvim_win_set_cursor(0, { r.row, r.col })
    end
  end
  vim.notify("No marker for [^" .. label .. "]")
end

-- ── ]f / [f ────────────────────────────────────────────────────────────────

function M.next_ref(dir)
  local row, col = unpack(api.nvim_win_get_cursor(0))
  local refs = all_refs(0)
  if dir > 0 then
    for _, r in ipairs(refs) do
      if r.row > row or (r.row == row and r.col > col) then
        return api.nvim_win_set_cursor(0, { r.row, r.col })
      end
    end
  else
    for i = #refs, 1, -1 do
      local r = refs[i]
      if r.row < row or (r.row == row and r.col < col) then
        return api.nvim_win_set_cursor(0, { r.row, r.col })
      end
    end
  end
  vim.notify(dir > 0 and "No footnote marker below" or "No footnote marker above")
end

-- ── helpers for new footnotes ─────────────────────────────────────────────

local function next_number(buf)
  local max = 0
  for _, line in ipairs(api.nvim_buf_get_lines(buf, 0, -1, false)) do
    for n in line:gmatch("%[%^(%d+)%]") do
      max = math.max(max, tonumber(n))
    end
  end
  return max + 1
end

-- ── renumber in reading order ──────────────────────────────────────────────

-- Footnote text blocks between the first and the last "[^x]:" line.
-- Returns blocks { {label=, lines={…}} … }, first row, last row, and whether
-- they were separated by blank lines; or nil if other text sits between them
-- (then the notes are renumbered but not re-sorted).
local function def_blocks(lines)
  local first
  for i, l in ipairs(lines) do
    if def_label(l) then first = i break end
  end
  if not first then return nil end
  local blocks, i, last, blank_sep = {}, first, first, false
  while i <= #lines do
    local l = lines[i]
    if l == "" then
      i = i + 1
    elseif def_label(l) then
      local block = { label = def_label(l), lines = { l } }
      local j = i + 1
      while j <= #lines do
        local m = lines[j]
        if def_label(m) then break end
        if m == "" then
          local nxt = lines[j + 1]
          if not (nxt and nxt:match("^%s+%S")) then break end
        end
        table.insert(block.lines, m)
        j = j + 1
      end
      if #blocks == 1 and lines[i - 1] == "" then blank_sep = true end
      table.insert(blocks, block)
      last = j - 1
      i = j
    else
      -- some other text: fine if no footnote text follows it, otherwise give up sorting
      for k = i, #lines do
        if def_label(lines[k]) then return nil end
      end
      break
    end
  end
  return blocks, first, last, blank_sep
end

-- Renumber numbered footnotes 1, 2, 3 … in the order their markers appear in the
-- text, and sort the footnote texts the same way. Named labels ([^smith]) stay.
-- Returns the old→new map.
function M.renumber(quiet)
  local buf = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local map, n = {}, 0
  for _, r in ipairs(all_refs(buf)) do
    if tonumber(r.label) and not map[r.label] then
      n = n + 1
      map[r.label] = tostring(n)
    end
  end
  for _, l in ipairs(lines) do -- texts without a marker go last
    local d = def_label(l)
    if d and tonumber(d) and not map[d] then
      n = n + 1
      map[d] = tostring(n)
    end
  end
  local changed = false
  for old, new in pairs(map) do
    if old ~= new then changed = true break end
  end

  local function relabel(l)
    return (l:gsub("%[%^(%d+)%]", function(d) return "[^" .. (map[d] or d) .. "]" end))
  end
  local new_lines = vim.tbl_map(relabel, lines)

  local blocks, first, last, blank_sep = def_blocks(new_lines)
  local sorted = false
  if blocks then
    local pos = {}
    for idx, b in ipairs(blocks) do pos[b] = idx end
    local ordered = vim.list_slice(blocks)
    table.sort(ordered, function(a, b)
      local na, nb = tonumber(a.label), tonumber(b.label)
      if na and nb then return na < nb end
      if na ~= nil and nb == nil then return true end
      if na == nil and nb ~= nil then return false end
      return pos[a] < pos[b]
    end)
    local section = {}
    for idx, b in ipairs(ordered) do
      if idx > 1 and blank_sep then table.insert(section, "") end
      vim.list_extend(section, b.lines)
    end
    local old_section = vim.list_slice(new_lines, first, last)
    if not vim.deep_equal(section, old_section) then
      sorted = true
      local rebuilt = vim.list_slice(new_lines, 1, first - 1)
      vim.list_extend(rebuilt, section)
      vim.list_extend(rebuilt, vim.list_slice(new_lines, last + 1))
      new_lines = rebuilt
    end
  end

  if changed or sorted then
    -- write back only what changed: one undo step, cursor stays put
    local view = vim.fn.winsaveview()
    local a, z = 1, #lines
    while a <= #lines and a <= #new_lines and lines[a] == new_lines[a] do a = a + 1 end
    local zn = #new_lines
    while z >= a and zn >= a and lines[z] == new_lines[zn] do z, zn = z - 1, zn - 1 end
    api.nvim_buf_set_lines(buf, a - 1, z, false, vim.list_slice(new_lines, a, zn))
    vim.fn.winrestview(view)
  end
  if not quiet then
    if not (changed or sorted) then
      vim.notify("Footnotes already in order")
    elseif blocks then
      vim.notify(("Footnotes renumbered 1–%d"):format(n))
    else
      vim.notify("Footnotes renumbered; texts not sorted (other text sits between them)")
    end
  end
  return map
end

-- ── new labeled footnote ───────────────────────────────────────────────────

-- Ctrl-f / Space n f: marker at the cursor, text line at the end, then renumber
-- so the numbers follow the text. You end up typing the footnote text.
function M.labeled(from_insert)
  local buf = 0
  local row, col = unpack(api.nvim_win_get_cursor(0))
  if not from_insert then
    local line = api.nvim_get_current_line()
    col = math.min(col + 1, #line) -- insert after the cursor, like `a`
  end
  local tmp = tostring(next_number(buf))
  local marker = "[^" .. tmp .. "]"
  api.nvim_buf_set_text(buf, row - 1, col, row - 1, col, { marker })

  -- remember where we were, so Ctrl-o (or Ctrl-f again) brings you back
  api.nvim_win_set_cursor(0, { row, col + #marker - 1 })
  vim.cmd("normal! m'")

  local last = api.nvim_buf_line_count(buf)
  local last_line = api.nvim_buf_get_lines(buf, last - 1, last, false)[1]
  local new = {}
  if last_line ~= "" then table.insert(new, "") end
  table.insert(new, marker .. ": ")
  if last_line == "" then
    api.nvim_buf_set_lines(buf, last - 1, last, false, new)
  else
    api.nvim_buf_set_lines(buf, last, last, false, new)
  end

  local label = M.renumber(true)[tmp] or tmp
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local drow = def_row(lines, label)
  api.nvim_win_set_cursor(0, { drow, #lines[drow] })
  vim.cmd("startinsert!")
end

-- Insert-mode Ctrl-f, a toggle between marker and note:
--   on or right after a marker  → jump to the end of its note, keep typing
--   on a footnote text line     → back to its marker, keep typing after it
--   anywhere else               → make a new footnote
function M.insert_toggle()
  local line = api.nvim_get_current_line()
  local label = def_label(line)
  if not label then
    local row, c = unpack(api.nvim_win_get_cursor(0))
    for _, r in ipairs(refs_in_line(line)) do
      if c + 1 >= r.s and c <= r.e then
        local lines = api.nvim_buf_get_lines(0, 0, -1, false)
        local drow = def_row(lines, r.label)
        if not drow then return vim.notify("No text for [^" .. r.label .. "]") end
        vim.cmd("stopinsert")
        vim.schedule(function()
          api.nvim_win_set_cursor(0, { row, r.e })
          vim.cmd("normal! m'")
          api.nvim_win_set_cursor(0, { drow, #lines[drow] })
          vim.cmd("startinsert!")
        end)
        return
      end
    end
    return M.labeled(true)
  end
  for _, r in ipairs(all_refs(0)) do
    if r.label == label then
      local after = r.col + #label + 3
      local line = api.nvim_buf_get_lines(0, r.row - 1, r.row, false)[1]
      vim.cmd("stopinsert")
      vim.schedule(function()
        if after >= #line then
          api.nvim_win_set_cursor(0, { r.row, #line })
          vim.cmd("startinsert!")
        else
          api.nvim_win_set_cursor(0, { r.row, after })
          vim.cmd("startinsert")
        end
      end)
      return
    end
  end
  vim.notify("No marker for [^" .. label .. "]")
end

-- ── :FootnoteCheck ─────────────────────────────────────────────────────────

function M.check()
  local buf = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local items, defs, seen, order = {}, {}, {}, {}
  local function add(lnum, col, text)
    table.insert(items, { bufnr = buf, lnum = lnum, col = col, text = text })
  end

  for i, line in ipairs(lines) do
    local d = def_label(line)
    if d then
      if defs[d] then
        add(i, 1, "[^" .. d .. "] has a second note (first on line " .. defs[d] .. ")")
      else
        defs[d] = i
      end
    end
  end
  for _, r in ipairs(all_refs(buf)) do
    if not seen[r.label] then
      seen[r.label] = true
      table.insert(order, r)
    end
    if not defs[r.label] then add(r.row, r.col + 1, "[^" .. r.label .. "] has no note") end
  end
  for label, row in pairs(defs) do
    if not seen[label] then add(row, 1, "note [^" .. label .. "] has no marker in the text") end
  end
  -- numbered markers should first appear as 1, 2, 3, … in reading order
  local expect = 1
  for _, r in ipairs(order) do
    local n = tonumber(r.label)
    if n then
      if n ~= expect then
        add(r.row, r.col + 1, "[^" .. n .. "] is out of order (expected [^" .. expect .. "] here)")
      end
      expect = expect + 1
    end
  end

  table.sort(items, function(a, b) return a.lnum < b.lnum end)
  vim.fn.setqflist({}, " ", { title = "FootnoteCheck", items = items })
  if #items == 0 then
    vim.cmd("cclose")
    vim.notify(("Footnotes OK: %d markers, %d notes"):format(#order, vim.tbl_count(defs)))
  else
    vim.cmd("copen")
  end
end

-- ── mappings ───────────────────────────────────────────────────────────────

local function attach(buf)
  if not api.nvim_buf_is_valid(buf) then return end
  local function o(desc) return { buffer = buf, silent = true, desc = desc } end
  vim.keymap.set("n", "s", M.hint, o("Footnote hints"))
  vim.keymap.set("n", "<CR>", M.enter, vim.tbl_extend("force", o("Footnote / Obsidian smart action"), { expr = true }))
  vim.keymap.set("n", "]f", function() M.next_ref(1) end, o("Next footnote marker"))
  vim.keymap.set("n", "[f", function() M.next_ref(-1) end, o("Previous footnote marker"))
  vim.keymap.set("n", "<leader>nf", function() M.labeled(false) end, o("New labeled footnote"))
  vim.keymap.set("i", "<C-f>", M.insert_toggle, o("New footnote / back to the text"))
  vim.keymap.set("n", "<leader>nc", M.check, o("Check footnotes"))
  vim.keymap.set("n", "<leader>nr", function() M.renumber() end, o("Renumber footnotes"))
end

api.nvim_create_user_command("FootnoteCheck", M.check, {})
api.nvim_create_user_command("FootnoteRenumber", function() M.renumber() end, {})

-- obsidian.nvim sets its own buffer-local Enter on FileType; attach again after it.
api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "pandoc" },
  callback = function(ev)
    attach(ev.buf)
    vim.schedule(function() attach(ev.buf) end)
  end,
})

return M
