---@diagnostic disable: invisible
vim.g.lz_n = {
    load = function() end,
}
local keys = require("lz.n.handler.keys")
local loader = require("lz.n.loader")
local spy = require("luassert.spy")

describe("handlers.keys", function()
    it("parses ids correctly", function()
        local tests = {
            { "<C-/>", "<c-/>", true },
            { "<C-h>", "<c-H>", true },
            { "<C-h>k", "<c-H>K", false },
        }
        for _, test in ipairs(tests) do
            if test[3] then
                local plguin = {}
                keys.parse(plguin, { test[1], test[2] })
                assert.same(plguin.keys[1].id, plguin.keys[2].id)
            else
                local plugin = {}
                keys.parse(plugin, { test[1], test[2] })
                assert.is_not.same(plugin.keys[1].id, plugin.keys[2].id)
            end
        end
    end)
    it("Key only loads plugin once", function()
        local lhs = "<leader>tt"
        ---@type lz.n.Plugin
        local plugin = {
            name = "foo",
        }
        keys.parse(plugin, lhs)
        local spy_load = spy.on(loader, "_load")
        keys.add(plugin)
        local feed = vim.api.nvim_replace_termcodes("<Ignore>" .. lhs, true, true, true)
        vim.api.nvim_feedkeys(feed, "ix", false)
        vim.api.nvim_feedkeys(feed, "ix", false)
        assert.spy(spy_load).called(1)
        --
    end)
    it("Multiple keys only load plugin once", function()
        ---@param fst string
        ---@param snd string
        local function itt(fst, snd)
            ---@type lz.n.Plugin
            local plugin = {
                name = "foo",
            }
            keys.parse(plugin, { fst, snd })
            local spy_load = spy.on(loader, "_load")
            keys.add(plugin)
            local feed1 = vim.api.nvim_replace_termcodes("<Ignore>" .. plugin.keys[1].lhs, true, true, true)
            vim.api.nvim_feedkeys(feed1, "ix", false)
            local feed2 = vim.api.nvim_replace_termcodes("<Ignore>" .. plugin.keys[2].lhs, true, true, true)
            vim.api.nvim_feedkeys(feed2, "ix", false)
            assert.spy(spy_load).called(1)
        end
        itt("<leader>tt", "<leader>ff")
        itt("<leader>ff", "<leader>tt")
    end)
    it("Plugins' keymaps are triggered", function()
        local lhs = "<leader>xy"
        ---@type lz.n.Plugin
        local plugin = {
            name = "baz",
        }
        keys.parse(plugin, lhs)
        local triggered = false
        local orig_load = loader._load
        ---@diagnostic disable-next-line: duplicate-set-field
        loader._load = function(...)
            vim.keymap.set("n", lhs, function()
                triggered = true
            end)
            orig_load(...)
        end
        keys.add(plugin)
        local feed = vim.api.nvim_replace_termcodes("<Ignore>" .. lhs, true, true, true)
        vim.api.nvim_feedkeys(feed, "ix", false)
        vim.api.nvim_feedkeys(feed, "x", false)
        assert.True(triggered)
        loader._load = orig_load
    end)
    it("Locally created keymaps are triggered", function()
        local triggered = false
        local lhs = "<leader>xz"
        ---@type lz.n.KeysSpec
        local keys_spec = {
            lhs,
            function()
                triggered = true
            end,
        }
        ---@type lz.n.Plugin
        local plugin = {
            name = "xz",
        }
        keys.parse(plugin, { keys_spec })
        keys.add(plugin)
        local feed = vim.api.nvim_replace_termcodes("<Ignore>" .. lhs, true, true, true)
        vim.api.nvim_feedkeys(feed, "ix", false)
        vim.api.nvim_feedkeys(feed, "x", false)
        assert.True(triggered)
    end)
end)
