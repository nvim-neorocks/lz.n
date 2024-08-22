vim.g.lz_n = {
    load = function() end,
}
local lz = require("lz.n")

---@type lz.n.PluginSpec
local cmd_testplugin = {
    "lookup_testplugin",
    cmd = "Telescope",
}
lz.load(cmd_testplugin)

---@type lz.n.PluginSpec
local colorscheme_testplugin = {
    "lookup_testplugin",
    colorscheme = "sweetie",
}
lz.load(colorscheme_testplugin)

describe("lookup", function()
    it("can influence which handlers to search", function()
        local result = lz.lookup("lookup_testplugin", { filter = "cmd" })
        assert.is_not_nil(result and result.cmd)
        result = lz.lookup("lookup_testplugin", { filter = "colorscheme" })
        assert.is_not_nil(result and result.colorscheme)
    end)
    it("can influence the order in which handlers are searched", function()
        local result = lz.lookup("lookup_testplugin", { filter = { "cmd", "colorscheme" } })
        assert.is_not_nil(result and result.cmd)
        result = lz.lookup("lookup_testplugin", { filter = { "colorscheme", "cmd" } })
        assert.is_not_nil(result and result.colorscheme)
    end)
end)
