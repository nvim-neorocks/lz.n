local keys = require("lz.n.handler.keys")
local state = require("lz.n.state")
local loader = require("lz.n.loader")
local spy = require("luassert.spy")

describe("keys", function()
    it("parses ids correctly", function()
        local tests = {
            { "<C-/>", "<c-/>", true },
            { "<C-h>", "<c-H>", true },
            { "<C-h>k", "<c-H>K", false },
        }
        for _, test in ipairs(tests) do
            if test[3] then
                assert.same(keys.parse(test[1]).id, keys.parse(test[2]).id)
            else
                assert.is_not.same(keys.parse(test[1]).id, keys.parse(test[2]).id)
            end
        end
    end)
    it("Key only loads plugin once", function()
        local lhs = "<leader>tt"
        ---@type LzPlugin
        local plugin = {
            name = "foo",
            keys = { keys.parse(lhs) },
        }
        local spy_load = spy.on(loader, "_load")
        state.plugins[plugin.name] = plugin
        keys.add(plugin)
        local feed = vim.api.nvim_replace_termcodes("<Ignore>" .. lhs, true, true, true)
        vim.api.nvim_feedkeys(feed, "ix", false)
        vim.api.nvim_feedkeys(feed, "ix", false)
        assert.spy(spy_load).called(1)
        --
    end)
end)
