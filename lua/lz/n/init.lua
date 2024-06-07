---@mod lz.n

local M = {}

-- TODO: Is this necessary?
if not vim.loader or vim.fn.has("nvim-0.9.1") ~= 1 then
    error("lz.n requires Neovim >= 0.9.1")
end

---@param spec string | lz.n.Spec
function M.load(spec)
    if vim.g.lzn_did_load then
        return vim.notify("lz.n has already loaded your plugins.", vim.log.levels.WARN, { title = "lz.n" })
    end
    vim.g.lzn_did_load = true

    if type(spec) == "string" then
        spec = { import = spec }
    end
    ---@cast spec lz.n.Spec
    local plugins = require("lz.n.spec").parse(spec)
    require("lz.n.loader").load_startup_plugins(plugins)
    require("lz.n.state").plugins = plugins
    require("lz.n.handler").init(plugins)
end

return M
