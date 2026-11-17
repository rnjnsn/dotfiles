-- Word and character count for the status line (lua/plugins/lualine.lua).
-- In markdown it counts the text as a reader sees it: no frontmatter, no footnote
-- texts ([^N]: …), no [^N] markers, no inline ^[…] footnotes, no markdown markup.
-- Characters include spaces but not line breaks. Elsewhere: Vim's own word count.
local M = {}
local api = vim.api

local function def_label(line)
  return line:match("^%[%^([^%]]+)%]:")
end

local function body_lines(lines)
  local out, i = {}, 1
  if lines[1] == "---" then -- YAML frontmatter
    i = 2
    while i <= #lines and lines[i] ~= "---" and lines[i] ~= "..." do i = i + 1 end
    i = i + 1
  end
  local in_def, prev_blank = false, false
  while i <= #lines do
    local l = lines[i]
    if def_label(l) then
      in_def = true
    elseif in_def and l == "" then
      local nxt = lines[i + 1]
      if not (nxt and nxt:match("^%s+%S")) then in_def = false end
    elseif in_def and (l:match("^%s+%S") or not prev_blank) then
      -- continuation of the footnote text
    else
      in_def = false
      if l ~= "" then
        l = l:gsub("%^%b[]", "")                      -- inline footnotes
             :gsub("%[%^[^%]]+%]", "")                -- footnote markers
             :gsub("<!%-%-.-%-%->", "")               -- html comments
             :gsub("%[%[([^%]|]-)|([^%]]-)%]%]", "%2") -- [[note|alias]] → alias
             :gsub("%[%[([^%]]-)%]%]", "%1")          -- [[note]] → note
             :gsub("!?%[([^%]]-)%]%b()", "%1")        -- [text](url) → text
             :gsub("^%s*#+%s+", "")                   -- headings
             :gsub("^%s*>%s?", "")                    -- block quotes
             :gsub("^%s*[-*+]%s+", "")                -- list bullets
             :gsub("[*_`]", "")                       -- emphasis, code ticks
             :gsub("\\(%p)", "%1")                    -- escaped punctuation \[ → [
        table.insert(out, l)
      end
    end
    prev_blank = (lines[i] == "")
    i = i + 1
  end
  return out
end

local cache = {}

-- { words = n, chars = n }, recomputed only when the buffer changes.
function M.stats(buf)
  buf = (buf == nil or buf == 0) and api.nvim_get_current_buf() or buf
  local tick = api.nvim_buf_get_changedtick(buf)
  local c = cache[buf]
  if c and c.tick == tick then return c end
  local words, chars = 0, 0
  for _, l in ipairs(body_lines(api.nvim_buf_get_lines(buf, 0, -1, false))) do
    chars = chars + vim.fn.strchars(l)
    for w in l:gmatch("%S+") do
      -- a word needs a letter or digit (æøå too); lone dashes, § etc. don't count
      if w:find("%w") or (w:find("[\128-\255]") and vim.fn.match(w, [[\k]]) >= 0) then
        words = words + 1
      end
    end
  end
  c = { tick = tick, words = words, chars = chars }
  cache[buf] = c
  return c
end

function M.statusline()
  local ft = vim.bo.filetype
  if ft == "markdown" or ft == "pandoc" then
    local s = M.stats(0)
    return ("Words: %d · Chars: %d"):format(s.words, s.chars)
  end
  return "Words: " .. vim.fn.wordcount().words
end

return M
