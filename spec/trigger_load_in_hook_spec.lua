---@diagnostic disable: invisible
vim.g.lz_n = {
    load = function() end,
}
local lz = require("lz.n")

describe("trigger_load in before/after hooks", function()
    for _, hook in ipairs({ "before", "after", "load" }) do
        it("resilient against state updates with a single event in " .. hook .. " hook", function()
            local i = 0
            while i < 50 do -- make sure it's not flaky
                i = i + 1
                local foo_load_count = 0
                local zoo_load_count = 0
                local hoo_load_count = 0
                local ignored_by_trigger_load
                lz.load({
                    {
                        "bar",
                        [hook] = function()
                            -- This should remove bar from the event handler's list
                            ignored_by_trigger_load = lz.trigger_load({ "foo", "zoo", "hoo" })
                        end,
                        event = "BufEnter",
                    },
                    {
                        "foo",
                        event = "BufEnter",
                        load = function()
                            foo_load_count = foo_load_count + 1
                        end,
                    },
                    {
                        "zoo",
                        event = "BufEnter",
                        load = function()
                            zoo_load_count = zoo_load_count + 1
                        end,
                    },
                    {
                        "hoo",
                        event = "BufEnter",
                        load = function()
                            hoo_load_count = hoo_load_count + 1
                        end,
                    },
                })
                vim.api.nvim_exec_autocmds("BufEnter", {})
                assert.is_not_nil(ignored_by_trigger_load) -- before invoked
                assert.same(1, foo_load_count)
                assert.same(1, zoo_load_count)
                assert.same(1, hoo_load_count)
            end
        end)
        it("resilient against state updates with multiple events in " .. hook .. " hook", function()
            local i = 0
            while i < 50 do -- make sure it's not flaky
                i = i + 1
                local load_count = 0
                lz.load({
                    {
                        "foo",
                        [hook] = function()
                            -- This should remove bar from the event handler's list
                            lz.trigger_load("bar")
                        end,
                        event = "BufReadPre",
                    },
                    {
                        "bar",
                        event = "BufEnter",
                        load = function()
                            load_count = load_count + 1
                        end,
                    },
                })
                vim.api.nvim_exec_autocmds("BufReadPre", {})
                vim.api.nvim_exec_autocmds("BufEnter", {})
                assert.same(1, load_count)
            end
        end)
    end
end)
