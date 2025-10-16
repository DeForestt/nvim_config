local M = {}

local function has_new_framework()
  return vim.lsp and vim.lsp.config
end

local function load_legacy()
  local ok, legacy = pcall(require, "lspconfig")
  if ok then
    return legacy
  end
  return nil
end

local notified_servers = {}

local function notify_once(msg, level, key)
  level = level or vim.log.levels.WARN
  if key then
    if notified_servers[key] then
      return
    end
    notified_servers[key] = true
  end

  vim.schedule(function()
    vim.notify(msg, level)
  end)
end

function M.get(server_name, opts)
  opts = opts or {}

  if has_new_framework() then
    local ok, server = pcall(function()
      return vim.lsp.config[server_name]
    end)

    if ok and server ~= nil then
      return server, "new"
    end
  end

  if opts.only_new then
    return nil, nil
  end

  local legacy = load_legacy()
  if legacy and legacy[server_name] then
    return legacy[server_name], "legacy"
  end

  return nil, nil
end

function M.setup(server_name, opts)
  opts = opts or {}

  if has_new_framework() then
    local ok, server = pcall(function()
      return vim.lsp.config[server_name]
    end)

    if ok and type(server) == "table" then
      if type(server.setup) == "function" then
        local success, err = pcall(server.setup, server, opts)
        if success then
          return true
        end

        notify_once(string.format(
          "vim.lsp.config setup for %s failed: %s. Falling back to legacy lspconfig.",
          server_name,
          err
        ), vim.log.levels.WARN, server_name .. "_fallback")
      elseif type(vim.lsp.config.setup) == "function" then
        local success, err = pcall(vim.lsp.config.setup, server_name, opts)
        if success then
          return true
        end

        notify_once(string.format(
          "vim.lsp.config.setup for %s failed: %s. Falling back to legacy lspconfig.",
          server_name,
          err
        ), vim.log.levels.WARN, server_name .. "_fallback")
      end
    end
  end

  local legacy = load_legacy()
  if legacy and legacy[server_name] and type(legacy[server_name].setup) == "function" then
    legacy[server_name].setup(opts)
    return true
  end

  notify_once(string.format("Unable to configure LSP server %s", server_name), vim.log.levels.ERROR, server_name .. "_error")
  return false
end

return M
