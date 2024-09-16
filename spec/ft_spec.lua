---@diagnostic disable: invisible
vim.g.lz_n = {
    load = function() end,
}
local ft = require("lz.n.handler.ft")
local loader = require("lz.n.loader")
local spy = require("luassert.spy")

describe("handlers.ft", function()
    it("can parse from string", function()
        local plugin = {}
        ft.parse(plugin, "rust")
        assert.same({
            {
                event = "FileType",
                id = "rust",
                pattern = "rust",
            },
        }, plugin.event)
    end)
    it("filetype event loads plugins", function()
        ---@type lz.n.Plugin
        local plugin = {
            name = "Foo",
        }
        ft.parse(plugin, "rust")
        local spy_load = spy.on(loader, "_load")
        ft.add(plugin)
        vim.api.nvim_exec_autocmds("FileType", { pattern = "rust" })
        vim.api.nvim_exec_autocmds("FileType", { pattern = "rust" })
        assert.spy(spy_load).called(1)
    end)
end)
