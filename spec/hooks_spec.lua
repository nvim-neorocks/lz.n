local lz = require("lz.n")
vim.g.lz_n = {
    load = function() end,
}

describe("hooks", function()
    it("beforeAll", function()
        local beforeAllRun = false
        lz.load({
            {
                "neorg",
                beforeAll = function()
                    beforeAllRun = true
                end,
            },
        })
        assert.True(beforeAllRun)
    end)
    it("before", function()
        local beforeRun = false
        lz.load({
            {
                "neorg",
                before = function()
                    beforeRun = true
                end,
            },
        })
        assert.True(beforeRun)
    end)
    it("after", function()
        local afterRun = false
        lz.load({
            {
                "neorg",
                beforeAll = function()
                    afterRun = true
                end,
            },
        })
        assert.True(afterRun)
    end)
end)
