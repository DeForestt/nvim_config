local ok, icons = pcall(require, "nvchad.icons")
local diagnostic_icons = {
  Error = " ",
  Warn = " ",
  Hint = " ",
  Info = " ",
}

if ok and type(icons) == "table" and type(icons.diagnostics) == "table" then
  diagnostic_icons = vim.tbl_extend("force", diagnostic_icons, icons.diagnostics)
end

local severity = vim.diagnostic.severity
local sign_text = {}

for name, icon in pairs(diagnostic_icons) do
  local sev = severity[string.upper(name)]
  if sev then
    sign_text[sev] = icon
  end
end

local current_config = vim.diagnostic.config()
vim.diagnostic.config(vim.tbl_deep_extend("force", current_config, {
  signs = {
    text = sign_text,
  },
}))
