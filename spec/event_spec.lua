local event = require("lz.n.handler.event")
local state = require("lz.n.state")
local loader = require("lz.n.loader")
local spy = require("luassert.spy")

describe("event", function()
    it("can parse from string", function()
        assert.same({
            event = "VimEnter",
            id = "VimEnter",
        }, event.parse("VimEnter"))
    end)
    it("can parse from table", function()
        assert.same(
            {
                event = "VimEnter",
                id = "VimEnter",
            },
            event.parse({
                event = "VimEnter",
            })
        )
        assert.same(
            {
                event = { "VimEnter", "BufEnter" },
                id = "VimEnter|BufEnter",
            },
            event.parse({
                event = { "VimEnter", "BufEnter" },
            })
        )
        assert.same(
            {
                event = "BufEnter",
                id = "BufEnter *.lua",
                pattern = "*.lua",
            },
            event.parse({
                event = "BufEnter",
                pattern = "*.lua",
            })
        )
    end)
    it("Event should only load plugin once", function()
        ---@type LzPlugin
        local plugin = {
            name = "foo",
            event = { event.parse("BufEnter") },
            pattern = ".lua",
        }
        local spy_load = spy.on(loader, "_load")
        state.plugins[plugin.name] = plugin
        event.add(plugin)
        vim.api.nvim_exec_autocmds("BufEnter", {})
        vim.api.nvim_exec_autocmds("BufEnter", {})
        assert.spy(spy_load).called(1)
    end)
    it("Multiple events should only load plugin once", function()
        ---@param events LzEvent[]
        local function itt(events)
            ---@type LzPlugin
            local plugin = {
                name = "foo",
                event = events,
            }
            local spy_load = spy.on(loader, "_load")
            state.plugins[plugin.name] = plugin
            event.add(plugin)
            vim.api.nvim_exec_autocmds(events[1].event, {
                pattern = ".lua",
            })
            vim.api.nvim_exec_autocmds(events[2].event, {
                pattern = ".lua",
            })
            assert.spy(spy_load).called(1)
        end
        itt({ event.parse("BufEnter"), event.parse("WinEnter") })
        itt({ event.parse("WinEnter"), event.parse("BufEnter") })
    end)
end)
