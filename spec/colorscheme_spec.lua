local colorscheme = require("lz.n.handler.colorscheme")
local state = require("lz.n.state")
local loader = require("lz.n.loader")
local spy = require("luassert.spy")

describe("handlers.colorscheme", function()
    it("Colorscheme only loads plugin once", function()
        ---@type lz.n.Plugin
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
