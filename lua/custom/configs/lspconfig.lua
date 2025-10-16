local base = require("plugins.configs.lspconfig")
local default_on_attach = base.on_attach
local capabilities = base.capabilities
local compat = require("custom.utils.lspconfig_compat")

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

local function detect_python()
  local uv = vim.uv or vim.loop

  local function join(...)
    return table.concat({ ... }, "/")
  end

  local function read_python_version_file(root)
    if not root then
      return nil
    end

    local path = join(root, ".python-version")
    local fd = uv.fs_open(path, "r", 438)
    if not fd then
      return nil
    end

    local stat = uv.fs_fstat(fd)
    local data = stat and uv.fs_read(fd, stat.size, 0) or nil
    uv.fs_close(fd)

    if data then
      local trim = vim.trim or vim.fn.trim
      return trim(data)
    end

    return nil
  end

  local function detect_pyenv_version(root)
    local version = os.getenv("PYENV_VERSION")
    if version and version ~= "" then
      return version
    end

    version = read_python_version_file(root)
    if version and version ~= "" then
      return version
    end

    local ok, result = pcall(vim.fn.systemlist, { "pyenv", "version-name" })
    if ok and result and result[1] and result[1] ~= "" and not result[1]:match("not found") then
      local trim = vim.trim or vim.fn.trim
      local version_name = trim(result[1])
      return version_name:match("^(%S+)") or version_name
    end

    return nil
  end

  local function detect_virtualenv(root)
    local venv = os.getenv("VIRTUAL_ENV")
    if venv and vim.fn.executable(join(venv, "bin", "python")) == 1 then
      return {
        python = join(venv, "bin", "python"),
        venv_path = vim.fn.fnamemodify(venv, ":h"),
        venv_name = vim.fn.fnamemodify(venv, ":t"),
      }
    end

    local pyenv_root = os.getenv("PYENV_ROOT") or join(vim.env.HOME, ".pyenv")
    local version = detect_pyenv_version(root)
    if version then
      local python = join(pyenv_root, "versions", version, "bin", "python")
      if vim.fn.executable(python) == 1 then
        return {
          python = python,
          venv_path = join(pyenv_root, "versions"),
          venv_name = version,
        }
      end
    end

    return nil
  end

  return {
    detect = detect_virtualenv,
  }
end

local python_env = detect_python()

local function setup(server, opts)
  compat.setup(server, opts)
end

setup("clangd", {
  on_attach = function(client, bufnr)
    client.server_capabilities.signatureHelpProvider = false
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
})

setup("pyright", {
  on_attach = default_on_attach,
  capabilities = capabilities,
  filetypes = { "python" },
  before_init = function(_, config)
    local env = python_env.detect(config.root_dir)
    if not env then
      return
    end

    config.settings = config.settings or {}
    config.settings.python = config.settings.python or {}
    config.settings.python.pythonPath = env.python
    config.settings.python.venvPath = env.venv_path
    config.settings.python.venv = env.venv_name
  end,
})

setup("rust_analyzer", {
  on_attach = function(client, bufnr)
    default_on_attach(client, bufnr)
    vim.lsp.inlay_hint.enable(bufnr, true)
  end,
  capabilities = capabilities,
})

-- TypeScript / JavaScript
-- Prefer the new server name "ts_ls" (typescript-language-server).
-- If your lspconfig is older, keep `tsserver` and the settings block is the same.
local _, ts_kind = compat.get("ts_ls", { only_new = true })
if not ts_kind then
  _, ts_kind = compat.get("tsserver")
end

local ts_name
if ts_kind == "new" then
  ts_name = "ts_ls"
else
  ts_name = "tsserver"
end

setup(ts_name, {
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

setup("asm_lsp", {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"asm"},
})

