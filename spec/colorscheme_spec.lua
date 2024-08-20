vim.g.lze = {
    load = function() end,
}
local colorscheme = require("lze.h.colorscheme")
local state = require("lze.c.state")
local loader = require("lze.c.loader")
local spy = require("luassert.spy")

describe("handlers.colorscheme", function()
    it("Colorscheme only loads plugin once", function()
        ---@type lze.Plugin
        local plugin = {
            name = "sweetie.nvim",
            colorscheme = { "sweetie" },
        }
        local spy_load = spy.on(loader, "_load")
        state.plugins[plugin.name] = plugin
        colorscheme.add(plugin)
        pcall(vim.cmd.colorscheme, "sweetie")
        pcall(vim.cmd.colorscheme, "sweetie")
        assert.spy(spy_load).called(1)
    end)
end)
