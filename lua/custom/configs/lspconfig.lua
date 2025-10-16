local base = require("plugins.configs.lspconfig")
local default_on_attach = base.on_attach
local capabilities = base.capabilities

local function on_attach(client, bufnr)
  default_on_attach(client, bufnr)

  -- optional: some people turn this off if they use a signature plugin
  if client.server_capabilities.signatureHelpProvider then
    client.server_capabilities.signatureHelpProvider = false
  end

  -- Neovim 0.10+ API (bufnr first)
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(bufnr, true)
  end
end

local lspconfig = vim.lsp and vim.lsp.config or require("lspconfig")

lspconfig.clangd.setup({
  on_attach = function(client, bufnr)
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
  on_attach = function(client, bufnr)
    default_on_attach(client, bufnr)
    vim.lsp.inlay_hint.enable(bufnr, true)
  end,
  capabilities = capabilities,
})

-- TypeScript / JavaScript
-- Prefer the new server name "ts_ls" (typescript-language-server).
-- If your lspconfig is older, keep `tsserver` and the settings block is the same.
local ts_server = lspconfig.ts_ls or lspconfig.tsserver
ts_server.setup({
  on_attach = function(client, bufnr)
    default_on_attach(client, bufnr)
    vim.lsp.inlay_hint.enable(bufnr, true)
  end,
  capabilities = capabilities,
  settings = {
    -- You need BOTH sections if you also edit JS.
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all", -- "none" | "literals" | "all"
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },

  init_options = {
     hostInfo = "neovim",
     preferences = {}, -- you can leave empty; settings above control inlay hints
     tsserver = {
       path = vim.fn.getcwd() .. "/node_modules/typescript/lib/tsserverlibrary.js",
     },
   },
})

lspconfig.asm_lsp.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"asm"},
})

