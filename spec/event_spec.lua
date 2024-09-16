---@diagnostic disable: invisible
vim.g.lz_n = {
    load = function() end,
}
local event = require("lz.n.handler.event")
local loader = require("lz.n.loader")
local spy = require("luassert.spy")

describe("handlers.event", function()
    it("can parse from string", function()
        local plugin = {}
        event.parse(plugin, "VimEnter")
        assert.same({ {
            event = "VimEnter",
            id = "VimEnter",
        } }, plugin.event)
    end)
    it("can parse from table", function()
        local plugin = {}
        event.parse(plugin, {
            event = "VimEnter",
        })
        assert.same({ {
            event = "VimEnter",
            id = "VimEnter",
        } }, plugin.event)
        plugin = {}
        event.parse(plugin, { event = { "VimEnter", "BufEnter" } })
        assert.same({
            {
                event = { "VimEnter", "BufEnter" },
                id = "VimEnter|BufEnter",
            },
        }, plugin.event)
        plugin = {}
        event.parse(plugin, {
            event = "BufEnter",
            pattern = "*.lua",
        })
        assert.same({
            {
                event = "BufEnter",
                id = "BufEnter *.lua",
                pattern = "*.lua",
            },
        }, plugin.event)
    end)
    it("Event only loads plugin once", function()
        ---@type lz.n.Plugin
        local plugin = {
            name = "foo",
        }
        event.parse(plugin, "BufEnter")
        local spy_load = spy.on(loader, "_load")
        event.add(plugin)
        vim.api.nvim_exec_autocmds("BufEnter", {})
        vim.api.nvim_exec_autocmds("BufEnter", {})
        assert.spy(spy_load).called(1)
    end)
    it("Multiple events only load plugin once", function()
        ---@param fst string
        ---@param snd string
        local function itt(fst, snd)
            ---@type lz.n.Plugin
            local plugin = {
                name = "foo",
            }
            event.parse(plugin, { fst, snd })
            local spy_load = spy.on(loader, "_load")
            event.add(plugin)
            vim.api.nvim_exec_autocmds(plugin.event[1].event, {
                pattern = ".lua",
            })
            vim.api.nvim_exec_autocmds(plugin.event[2].event, {
                pattern = ".lua",
            })
            assert.spy(spy_load).called(1)
        end
        itt("BufEnter", "WinEnter")
        itt("WinEnter", "BufEnter")
    end)
    it("Plugins' event handlers are triggered", function()
        ---@type lz.n.Plugin
        local plugin = {
            name = "foo",
        }
        event.parse(plugin, "BufEnter")
        local triggered = false
        local orig_load = loader._load
        ---@diagnostic disable-next-line: duplicate-set-field
        loader._load = function(...)
            orig_load(...)
            vim.api.nvim_create_autocmd("BufEnter", {
                callback = function()
                    triggered = true
                end,
                group = vim.api.nvim_create_augroup("foo", {}),
            })
        end
        event.add(plugin)
        vim.api.nvim_exec_autocmds("BufEnter", {})
        assert.True(triggered)
        loader._load = orig_load
    end)
    it("DeferredUIEnter", function()
        ---@type lz.n.Plugin
        local plugin = {
            name = "bla",
        }
        event.parse(plugin, "DeferredUIEnter")
        local spy_load = spy.on(loader, "_load")
        event.add(plugin)
        vim.api.nvim_exec_autocmds("User", { pattern = "DeferredUIEnter", modeline = false })
        assert.spy(spy_load).called(1)
    end)
end)
