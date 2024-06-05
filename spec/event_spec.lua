local event = require("lz.n.handler.event")
-- local loader = require("lz.n.loader")

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
    it("integration", function()
        ---@type LzPlugin
        local plugin = {
            name = "foo",
            event = { { id = "BufEnter", event = "BufEnter" } },
            pattern = ".lua",
        }
        event.add(plugin)
        -- TODO
    end)
end)
