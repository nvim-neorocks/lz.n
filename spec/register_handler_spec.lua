---@diagnostic disable: invisible
vim.g.lz_n = {
    load = function() end,
}
local lz_n = require("lz.n")
local spy = require("luassert.spy")

---@type lz.n.Plugin
local testplugin = {
    name = "testplugin",
    testfield = { "a", "b" },
    lazy = true,
}

describe("handlers.custom", function()
    ---@class TestHandler: lz.n.Handler
    local mock_state = {}
    ---@type TestHandler
    local mock_hndl = {
        spec_field = "testfield",
        add = function(plugin)
            mock_state[plugin.name] = plugin
        end,
        del = function(plugin)
            mock_state[plugin.name] = nil
        end,
        ---@param name string
        ---@return lz.n.Plugin?
        lookup = function(name)
            return mock_state[name]
        end,
    }

    local addspy = spy.on(mock_hndl, "add")
    local delspy = spy.on(mock_hndl, "del")
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
        assert.True(lz_n.register_handler(mock_hndl))
        lz_n.load({
            "testplugin",
            testfield = { "a", "b" },
        })
        assert.spy(addspy).called_with(testplugin)
    end)
    it("loading a plugin removes it from the handler", function()
        lz_n.trigger_load(testplugin.name)
        assert.spy(delspy).called_with(testplugin)
    end)
    it("trigger_load is idempotent when called with a plugin name", function()
        lz_n.trigger_load(testplugin.name)
        assert.spy(delspy).called(1)
    end)
end)
