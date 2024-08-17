---@diagnostic disable: invisible
vim.g.lz_n = {
    load = function() end,
}
local cmd = require("lz.n.handler.cmd")
local state = require("lz.n.state")
local loader = require("lz.n.loader")
local spy = require("luassert.spy")

describe("handlers.cmd", function()
    it("Command only loads plugin once and executes plugin command", function()
        ---@type lz.n.Plugin
        local plugin = {
            name = "foo",
            cmd = { "Foo" },
        }
        local spy_load = spy.on(loader, "_load")
        state.plugins[plugin.name] = plugin
        cmd.add(plugin)
        assert.is_not_nil(vim.cmd.Foo)
        local counter = 0
        local orig_load = loader._load
        ---@diagnostic disable-next-line: duplicate-set-field
        loader._load = function(...)
            orig_load(...)
            vim.api.nvim_create_user_command("Foo", function()
                counter = counter + 1
            end, {})
        end
        vim.cmd.Foo()
        vim.cmd.Foo()
        assert.spy(spy_load).called(1)
        assert.same(2, counter)
        loader._load = orig_load
        assert.True(state.loaded[plugin.name])
        state.loaded[plugin.name] = false
    end)
    it("Multiple commands only load plugin once", function()
        ---@param commands string[]
        local function itt(commands)
            local orig_load = loader._load
            ---@diagnostic disable-next-line: duplicate-set-field
            loader._load = function(...)
                orig_load(...)
                vim.api.nvim_create_user_command("Foo", function() end, {})
                vim.api.nvim_create_user_command("Bar", function() end, {})
            end
            ---@type lz.n.Plugin
            local plugin = {
                name = "foo",
                cmd = commands,
            }
            local spy_load = spy.on(loader, "_load")
            state.plugins[plugin.name] = plugin
            cmd.add(plugin)
            vim.cmd[commands[1]]()
            vim.cmd[commands[2]]()
            assert.spy(spy_load).called(1)
            loader._load = orig_load
            assert.True(state.loaded[plugin.name])
            state.loaded[plugin.name] = false
        end
        itt({ "Foo", "Bar" })
        itt({ "Bar", "Foo" })
    end)
end)
