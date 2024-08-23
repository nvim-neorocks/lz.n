vim.g.lz_n = {
    load = function() end,
}
local lz = require("lz.n")

---@type lz.n.PluginSpec
local testplugin = {
    "trigger_load_testplugin",
    cmd = "Foo",
}
lz.load(testplugin)

describe("trigger_load", function()
    it("returns a list of skipped plugins", function()
        local skipped = lz.trigger_load({ "trigger_load_testplugin", "unknown_testplugin" })
        assert.same({ "unknown_testplugin" }, skipped)
    end)
end)
