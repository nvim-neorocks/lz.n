describe("nested events", function()
    it("lazy-loaded colorscheme triggered by UIEnter event", function()
        require("lz.n").load({
            {
                "sweetie.nvim",
                colorscheme = "sweetie",
                load = function()
                    vim.g.sweetie_nvim_loaded = true
                end,
            },
            {
                "xyz",
                event = "UIEnter",
                after = function()
                    pcall(vim.cmd.colorscheme, "sweetie")
                end,
                load = function() end,
            },
        })
        vim.api.nvim_exec_autocmds("UIEnter", {})
        assert.True(vim.g.sweetie_nvim_loaded)
    end)
end)
