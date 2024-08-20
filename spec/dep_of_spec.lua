local lze = require("lze")

describe("handlers.dep_of", function()
    ---@class state_entry_deps
    ---@field load_called? boolean
    ---@field after_called? boolean
    ---@field before_called? boolean
    ---@field loaded_after? string[]
    ---@field loaded_after_before? string[]
    ---@field loaded_after_after? string[]

    ---@type table<string, state_entry_deps>
    local plugin_state = {}

    local filter_states = function(plugin, filter)
        return vim.iter(plugin_state)
            :filter(function(name, _)
                return name ~= plugin.name
            end)
            :filter(filter)
            :map(function(n, _)
                return n
            end)
            :totable()
    end

    local test_load_fun = function(plugin)
        if plugin_state[plugin] == nil then
            plugin_state[plugin] = {}
        end
        plugin_state[plugin] = vim.tbl_extend("force", plugin_state[plugin], {
            load_called = true,
            loaded_after = filter_states(plugin, function(_, v)
                return v.load_called
            end),
            loaded_after_after = filter_states(plugin, function(_, v)
                return v.after_called
            end),
            loaded_after_before = filter_states(plugin, function(_, v)
                return v.before_called
            end),
        })
    end

    local test_before_fun = function(plugin)
        if plugin_state[plugin.name] == nil then
            plugin_state[plugin.name] = {}
        end
        plugin_state[plugin.name].before_called = true
    end
    local test_after_fun = function(plugin)
        if plugin_state[plugin.name] == nil then
            plugin_state[plugin.name] = {}
        end
        plugin_state[plugin.name].after_called = true
    end

    local test_plugin = {
        "test_plugin",
        lazy = true,
        load = test_load_fun,
        before = test_before_fun,
        after = test_after_fun,
    }
    local test_plugin_2 = {
        "test_plugin_2",
        dep_of = { "test_plugin" },
        load = test_load_fun,
        before = test_before_fun,
        after = test_after_fun,
    }
    local tpl = vim.tbl_extend("keep", test_plugin, { lazy = true })
    tpl.name = tpl[1]
    tpl[1] = nil

    local tpl_2 = vim.tbl_extend("error", test_plugin_2, { lazy = true })
    tpl_2.name = tpl_2[1]
    tpl_2[1] = nil

    it("dep_of loads after before and before load", function()
        lze.load(test_plugin)
        lze.load(test_plugin_2)
        lze.trigger_load(tpl.name)

        assert.same(true, plugin_state[tpl.name].load_called)
        assert.same(true, plugin_state[tpl.name].before_called)
        assert.same(true, plugin_state[tpl.name].after_called)
        assert.same({ "test_plugin_2" }, plugin_state[tpl.name].loaded_after)
        assert.same({ "test_plugin_2" }, plugin_state[tpl.name].loaded_after_after)
        assert.True(vim.tbl_contains(plugin_state[tpl.name].loaded_after_before, "test_plugin"))
        assert.True(vim.tbl_contains(plugin_state[tpl.name].loaded_after_before, "test_plugin_2"))

        assert.same(true, plugin_state[tpl_2.name].load_called)
        assert.same(true, plugin_state[tpl_2.name].before_called)
        assert.same(true, plugin_state[tpl_2.name].after_called)
        assert.same({}, plugin_state[tpl_2.name].loaded_after)
        assert.same({}, plugin_state[tpl_2.name].loaded_after_after)
        assert.True(vim.tbl_contains(plugin_state[tpl_2.name].loaded_after_before, "test_plugin"))
        assert.True(vim.tbl_contains(plugin_state[tpl_2.name].loaded_after_before, "test_plugin_2"))
    end)
end)
