local Client = require 'vim.lsp.client'
local orig_request = Client.request

---Override LSP client request to accept function bufnr values.
---@param self table
---@param method string
---@param params table
---@param handler function|nil
---@param bufnr number|function|nil
function Client.request(self, method, params, handler, bufnr)
  if type(bufnr) == 'function' then
    bufnr = bufnr()
  end
  return orig_request(self, method, params, handler, bufnr)
end

return Client
