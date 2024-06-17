local lz = require("lz.n")
vim.g.lz_n = {
    load = function() end,
}
local tempdir = vim.fn.tempname()
vim.system({ "rm", "-r", tempdir }):wait()
vim.system({ "mkdir", "-p", tempdir .. "/lua/plugins" }):wait()

local loader = require("lz.n.loader")
local spy = require("luassert.spy")

describe("lz.n", function()
    describe("load", function()
        it("import", function()
            vim.g.lz_n_did_load = false
            local plugin_config_content = [[
return {
  "telescope.nvim",
  cmd = "Telescope",
}
]]
            local spec_file = vim.fs.joinpath(tempdir, "lua", "plugins", "telescope.lua")
            local fh = assert(io.open(spec_file, "w"), "Could not open config file for writing")
            fh:write(plugin_config_content)
            fh:close()
            vim.opt.runtimepath:append(tempdir)
            local spy_load = spy.on(loader, "_load")
            lz.load("plugins")
            vim.cmd.Telescope()
            assert.spy(spy_load).called(1)
            vim.system({ "rm", spec_file }):wait()
        end)
        it("import root file", function()
            vim.g.lz_n_did_load = false
            local plugin_config_content = [[
return {
    { "sweetie.nvim" },
    { "telescope.nvim", cmd = "Telescope" },
}
]]
            local spec_file = vim.fs.joinpath(tempdir, "lua", "plugins.lua")
            local fh = assert(io.open(spec_file, "w"), "Could not open config file for writing")
            fh:write(plugin_config_content)
            fh:close()
            vim.opt.runtimepath:append(tempdir)
            local spy_load = spy.on(loader, "_load")
            lz.load("plugins")
            assert.spy(spy_load).called(1)
            vim.cmd.Telescope()
            assert.spy(spy_load).called(2)
            vim.system({ "rm", spec_file }):wait()
        end)
        it("import plugin specs and spec file", function()
            vim.g.lz_n_did_load = false
            local plugin_config_content = [[
return {
  "telescope.nvim",
  cmd = "Telescope",
}
]]
            local spec_file = vim.fs.joinpath(tempdir, "lua", "plugins", "telescope.lua")
            local fh = assert(io.open(spec_file, "w"), "Could not open config file for writing")
            fh:write(plugin_config_content)
            fh:close()
            vim.opt.runtimepath:append(tempdir)
            local spy_load = spy.on(loader, "_load")
            lz.load({
                { import = "plugins" },
                { "sweetie.nvim" },
            })
            assert.spy(spy_load).called(1)
            vim.cmd.Telescope()
            assert.spy(spy_load).called(2)
            vim.system({ "rm", spec_file }):wait()
        end)
    end)
end)
