local lze = require("lze")
local spy = require("luassert.spy")

describe("handlers.custom", function()
    ---@class state_entry
    ---@field load_called boolean
    ---@field after_load_called_after? boolean

    ---@type table<string, state_entry>
    local plugin_state = {}

    ---@class TestHandler: lze.Handler
    ---@type TestHandler
    local hndl = {
        spec_field = "testfield",
        add = function(_) end,
        before = function(_) end,
        after = function(plugin)
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
    local delspy = spy.on(hndl, "before")
    local afterspy = spy.on(hndl, "after")

    it("Duplicate handlers fail to register", function()
        assert.same({}, lze.register_handlers(require("lze.h.ft")))
    end)
    it("can add plugins to the handler", function()
        assert.same({ hndl.spec_field }, lze.register_handlers(hndl))
        lze.load(test_plugin)
        assert.spy(addspy).called_with(test_plugin_loaded)
    end)
    it("loading a plugin calls before", function()
        lze.trigger_load("testplugin")
        assert.spy(delspy).called_with(test_plugin_loaded)
    end)
    it("handler after is called after load", function()
        assert.spy(afterspy).called_with(test_plugin_loaded)
        assert.True(plugin_state["testplugin"].load_called)
        assert.True(plugin_state["testplugin"].after_load_called_after)
    end)
end)
