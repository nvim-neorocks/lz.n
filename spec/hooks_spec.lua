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
                after = function()
                    afterRun = true
                end,
            },
        })
        assert.True(afterRun)
    end)
    describe("regression-#187", function()
        it("hook run when `lazy = false`", function()
            local beforeAllRun = false
            local beforeRun = false
            local afterRun = false
            lz.load({
                {
                    "neorg",
                    lazy = false,
                    beforeAll = function()
                        beforeAllRun = true
                    end,
                    before = function()
                        beforeRun = true
                    end,
                    after = function()
                        afterRun = true
                    end,
                },
            })
            assert.True(beforeAllRun)
            assert.True(beforeRun)
            assert.True(afterRun)
        end)
    end)
end)
