local loaded_plugin

---@diagnostic disable: invisible
vim.g.lz_n = {
    load = function(plugin)
        loaded_plugin = plugin
    end,
}
local lz_n = require("lz.n")

---@param lhs string
local function feedkeys(lhs)
    local feed = vim.api.nvim_replace_termcodes("<Ignore>" .. lhs, true, true, true)
    vim.api.nvim_feedkeys(feed, "ix", false)
    vim.api.nvim_feedkeys(feed, "x", false)
end

describe("keymap('<plugin>').set", function()
    it("extends pending plugins", function()
        local foo_loaded = false
        lz_n.load({
            "foo",
            cmd = "Foo",
            before = function()
                foo_loaded = true
            end,
        })
        assert.False(foo_loaded)
        local lhs = "<leader>f"
        local invoked = false
        lz_n.keymap("foo").set("n", lhs, function()
            invoked = true
        end, {})
        feedkeys(lhs)
        assert.True(foo_loaded)
        assert.True(invoked)
    end)
    it("works without prior 'load'", function()
        loaded_plugin = nil
        local lhs = "<leader>b"
        lz_n.keymap("bar").set("n", lhs, function() end, {})
        feedkeys(lhs)
        assert.are_equal("bar", loaded_plugin)
    end)
    it("loads plugin spec", function()
        local loaded = false
        local lhs = "<leader>c"
        lz_n.keymap({
            "cat",
            load = function()
                loaded = true
            end,
        }).set("n", lhs, function() end, {})
        feedkeys(lhs)
        assert.True(loaded)
    end)
    it("can set multiple keymaps", function()
        loaded_plugin = nil
        local a_invoked = false
        local b_invoked = false
        local lhs_a = "<leader>ta"
        local lhs_b = "<leader>tb"
        local load_count = 0
        local keymap = lz_n.keymap({
            "bat",
            load = function()
                loaded_plugin = "bat"
                load_count = load_count + 1
            end,
        })
        keymap.set("n", lhs_a, function()
            a_invoked = true
        end, {})
        keymap.set("n", lhs_b, function()
            b_invoked = true
        end, {})
        feedkeys(lhs_a)
        feedkeys(lhs_b)
        assert.True(a_invoked)
        assert.True(b_invoked)
        assert.are_equal(1, load_count)
        assert.are_equal("bat", loaded_plugin)
    end)
end)
