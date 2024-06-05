local event = require("lz.n.handler.event")

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
end)
