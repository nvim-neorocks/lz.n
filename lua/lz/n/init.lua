---@mod lz.n

local M = {}

if vim.fn.has("nvim-0.10.0") ~= 1 then
    error("lz.n requires Neovim >= 0.10.0")
end

local deferred_ui_enter = vim.schedule_wrap(function()
    if vim.v.exiting ~= vim.NIL then
        return
    end
    vim.g.lz_n_did_deferred_ui_enter = true
    vim.api.nvim_exec_autocmds("User", { pattern = "DeferredUIEnter", modeline = false })
end)

---@param spec string | lz.n.Spec
function M.load(spec)
    if vim.g.lz_n_did_load then
        return vim.notify("lz.n has already loaded your plugins.", vim.log.levels.WARN, { title = "lz.n" })
    end
    vim.g.lz_n_did_load = true

    if type(spec) == "string" then
        spec = { import = spec }
    end
    ---@cast spec lz.n.Spec
    local plugins = require("lz.n.spec").parse(spec)
    require("lz.n.loader").load_startup_plugins(plugins)
    require("lz.n.state").plugins = plugins
    require("lz.n.handler").init(plugins)
    if vim.v.vim_did_enter == 1 then
        deferred_ui_enter()
    else
        vim.api.nvim_create_autocmd("UIEnter", {
            once = true,
            callback = deferred_ui_enter,
        })
    end
end

return M
