---@diagnostic disable: invisible
local ft = require("lz.n.handler.ft")
local state = require("lz.n.state")
local loader = require("lz.n.loader")
local spy = require("luassert.spy")

describe("handlers.ft", function()
    it("can parse from string", function()
        assert.same({
            event = "FileType",
            id = "rust",
            pattern = "rust",
        }, ft.parse("rust"))
    end)
    it("filetype event loads plugins", function()
        ---@type lz.n.Plugin
        local plugin = {
            name = "Foo",
            event = { ft.parse("rust") },
        }
        local spy_load = spy.on(loader, "_load")
        state.plugins[plugin.name] = plugin
        ft.add(plugin)
        vim.api.nvim_exec_autocmds("FileType", { pattern = "rust" })
        vim.api.nvim_exec_autocmds("FileType", { pattern = "rust" })
        assert.spy(spy_load).called(1)
    end)
end)
