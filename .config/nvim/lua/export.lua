-- :Export [pdf|docx]  Export the current markdown file with pandoc.
-- Uses the defaults files in ~/.local/share/pandoc/defaults/ (pdf.yaml = typst,
-- docx.yaml). Output goes to ~/docs/exports/<name>.<ext>, outside the vault, so
-- Obsidian Sync and the curator never see it. The first PDF export of a file
-- opens it in zathura, which reloads by itself on later exports.
local M = {}

local outdir = vim.fn.expand("~/docs/exports")
local opened = {}

function M.export(fmt)
  fmt = (fmt and fmt ~= "") and fmt or "pdf"
  if fmt ~= "pdf" and fmt ~= "docx" then
    return vim.notify("Export: use pdf or docx", vim.log.levels.ERROR)
  end
  local src = vim.api.nvim_buf_get_name(0)
  if src == "" then return vim.notify("Export: save the file first", vim.log.levels.ERROR) end
  vim.cmd("silent update")

  vim.fn.mkdir(outdir, "p")
  local out = outdir .. "/" .. vim.fn.fnamemodify(src, ":t:r") .. "." .. fmt
  vim.notify("Exporting " .. fmt .. "…")
  vim.system(
    { "pandoc", "-d", fmt, src, "-o", out },
    { cwd = vim.fn.fnamemodify(src, ":h"), text = true },
    vim.schedule_wrap(function(r)
      if r.code ~= 0 then
        return vim.notify("Export failed:\n" .. (r.stderr or ""), vim.log.levels.ERROR)
      end
      local msg = "Exported " .. out:gsub("^" .. vim.pesc(vim.env.HOME), "~")
      if r.stderr and r.stderr ~= "" then msg = msg .. "\n" .. r.stderr end
      vim.notify(msg)
      if fmt == "pdf" and not opened[out] then
        opened[out] = true
        vim.system({ "zathura", out }, { detach = true })
      end
    end)
  )
end

vim.api.nvim_create_user_command("Export", function(a) M.export(a.args) end, {
  nargs = "?",
  complete = function() return { "pdf", "docx" } end,
  desc = "Export markdown to ~/docs/exports with pandoc (pdf via typst, or docx)",
})

return M
