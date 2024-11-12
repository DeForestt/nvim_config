local base = require("plugins.configs.lspconfig")
local default_on_attach = base.on_attach
local capabilities = base.capabilities

local function on_attach(client, bufnr)
  default_on_attach(client, bufnr)
  if client.server_capabilities.signatureHelpProvider then
    client.server_capabilities.signatureHelpProvider = false
  end
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true)
  end
end

local lspconfig = require("lspconfig")

lspconfig.clangd.setup({
  on_attach = function (client, bufnr)
    client.server_capabilities.signatureHelpProvider = false
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
})

lspconfig.pyright.setup({
  on_attach = default_on_attach,
  capabilities = capabilities,
  filetypes = {"python"},
})

lspconfig.rust_analyzer.setup({
  on_attach = function (client, bufnr)
    default_on_attach(client, bufnr)
    vim.lsp.inlay_hint.enable(true)
    
  end,
  capabilities = capabilities,
})

lspconfig.tsserver.setup({
  on_attach = function (client, bufnr)
    default_on_attach(client, bufnr)
    vim.lsp.inlay_hint.enable(true)
  end,
  capabilities = capabilities,
})

lspconfig.asm_lsp.setup({
  on_attach=on_attach,
  capabilities=capabilities,
  filetypes = {"asm"}
})
