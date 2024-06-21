---@diagnostic disable: invisible
vim.g.lz_n = {
    load = function() end,
}
local lz_n = require("lz.n")
local spy = require("luassert.spy")

describe("handlers.custom", function()
    ---@class TestHandler: lz.n.Handler
    ---@type TestHandler
    local hndl = {
        spec_field = "testfield",
        add = function(_) end,
        del = function(_) end,
    }
    local addspy = spy.on(hndl, "add")
    local delspy = spy.on(hndl, "del")
    it("Duplicate handlers fail to register", function()
        local notispy = spy.new(function() end)
        -- NOTE: teardown fails if you don't temporarily replace vim.notify
        local og_notify = vim.notify
        vim.notify = notispy
        assert.False(lz_n.register_handler(require("lz.n.handler.ft")))
        assert.spy(notispy).called(1)
        vim.notify = og_notify
    end)
    it("can add plugins to the handler", function()
        assert.True(lz_n.register_handler(hndl))
        lz_n.load({
            "testplugin",
            testfield = { "a", "b" },
        })
        assert.spy(addspy).called_with({
            name = "testplugin",
            testfield = { "a", "b" },
            lazy = true,
        })
    end)
    it("loading a plugin removes it from the handler", function()
        lz_n.trigger_load("testplugin")
        assert.spy(delspy).called_with({
            name = "testplugin",
            testfield = { "a", "b" },
            lazy = true,
        })
    end)
end)
