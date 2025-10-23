local base = require("plugins.configs.lspconfig")
local default_on_attach = base.on_attach
local capabilities = base.capabilities
local load_server = base.load_server

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

local function get_server(name, ...)
  local candidates = { name, ... }

  for _, candidate in ipairs(candidates) do
    local server = load_server(candidate)
    if server then
      return server
    end
  end

  vim.notify("LSP server '" .. name .. "' is not available in nvim-lspconfig", vim.log.levels.WARN)
end

local clangd = get_server "clangd"
if clangd then
  clangd.setup({
    on_attach = function(client, bufnr)
      client.server_capabilities.signatureHelpProvider = false
      on_attach(client, bufnr)
    end,
    capabilities = capabilities,
  })
end

local pyright = get_server "pyright"
if pyright then
  pyright.setup({
    on_attach = default_on_attach,
    capabilities = capabilities,
    filetypes = {"python"},
  })
end

local rust_analyzer = get_server "rust_analyzer"
if rust_analyzer then
  rust_analyzer.setup({
    on_attach = function(client, bufnr)
      default_on_attach(client, bufnr)
      vim.lsp.inlay_hint.enable(bufnr, true)
    end,
    capabilities = capabilities,
  })
end

-- TypeScript / JavaScript
-- Prefer the new server name "ts_ls" (typescript-language-server).
-- If your lspconfig is older, keep `tsserver` and the settings block is the same.
local ts_server = get_server("ts_ls", "tsserver")
if ts_server then
  ts_server.setup({
    on_attach = function(client, bufnr)
      default_on_attach(client, bufnr)
      vim.lsp.inlay_hint.enable(bufnr, true)
    end,
    capabilities = capabilities,
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },
  })
end

local volar = get_server "volar"
if volar then
  volar.setup({
    on_attach = function(client, bufnr)
      default_on_attach(client, bufnr)
      vim.lsp.inlay_hint.enable(bufnr, true)
    end,
    capabilities = capabilities,
    filetypes = { "vue" },
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
end

local asm_lsp = get_server "asm_lsp"
if asm_lsp then
  asm_lsp.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = {"asm"},
  })
end

