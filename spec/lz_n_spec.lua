local lz = require("lz.n")
vim.g.lz_n = {
    load = function() end,
}
local loader = require("lz.n.loader")
local spy = require("luassert.spy")

describe("lz.n", function()
    it("load", function()
        local spy_load = spy.on(loader, "_load")
        lz.load({
            {
                "neorg",
            },
            {
                "crates.nvim",
                ft = { "toml", "rust" },
            },
            {
                "telescope.nvim",
                keys = "<leader>tt",
                cmd = "Telescope",
            },
        })
        assert.spy(spy_load).called(1)
        assert.spy(spy_load).called_with({
            name = "neorg",
            lazy = false,
        })
        vim.api.nvim_exec_autocmds("FileType", { pattern = "toml" })
        assert.spy(spy_load).called(2)
        assert.spy(spy_load).called_with({
            name = "crates.nvim",
            lazy = true,
            event = {
                require("lz.n.handler.ft").parse("toml"),
                require("lz.n.handler.ft").parse("rust"),
            },
        })
        vim.cmd.Telescope()
        assert.spy(spy_load).called(3)
        assert.spy(spy_load).called_with({
            name = "telescope.nvim",
            lazy = true,
            cmd = { "Telescope" },
            keys = { require("lz.n.handler.keys").parse("<leader>tt") },
        })
    end)
end)
