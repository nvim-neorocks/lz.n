local lz_n = require("lz.n")
local spy = require("luassert.spy")

describe("handlers.custom", function()
    ---@class state_entry
    ---@field load_called boolean
    ---@field after_load_called_after? boolean

    ---@type table<string, state_entry>
    local plugin_state = {}

    ---@class TestHandler: lz.n.Handler
    ---@type TestHandler
    local hndl = {
        spec_field = "testfield",
        add = function(_) end,
        del = function(_) end,
        after_load = function(plugin)
            if plugin_state[plugin.name] and plugin_state[plugin.name].load_called then
                plugin_state[plugin.name] =
                    vim.tbl_extend("error", plugin_state[plugin.name], { after_load_called_after = true })
                return
            end
            plugin_state[plugin.name] =
                vim.tbl_extend("error", plugin_state[plugin.name] or {}, { after_load_called_after = false })
        end,
    }

    local test_plugin = {
        "testplugin",
        testfield = { "a", "b" },
        load = function(plugin)
            plugin_state[plugin] = {
                load_called = true,
            }
        end,
    }
    local test_plugin_loaded = vim.tbl_extend("error", test_plugin, { lazy = true })
    test_plugin_loaded.name = test_plugin_loaded[1]
    test_plugin_loaded[1] = nil

    local addspy = spy.on(hndl, "add")
    local delspy = spy.on(hndl, "del")
    local afterspy = spy.on(hndl, "after_load")

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
        lz_n.load(test_plugin)
        assert.spy(addspy).called_with(test_plugin_loaded)
    end)
    it("loading a plugin removes it from the handler", function()
        lz_n.trigger_load("testplugin")
        assert.spy(delspy).called_with(test_plugin_loaded)
    end)
    it("handler after_load is called after load", function()
        assert.spy(afterspy).called_with(test_plugin_loaded)
        assert.True(plugin_state["testplugin"].load_called)
        assert.True(plugin_state["testplugin"].after_load_called_after)
    end)
end)
