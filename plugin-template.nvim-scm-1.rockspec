-- NOTE: This rockspec is used for running busted tests only,
-- not for publishing to LuaRocks.org

-- TODO: Rename this file

local _MODREV, _SPECREV = 'scm', '-1'
rockspec_format = '3.0'
package = 'plugin-template.nvim' -- TODO: Set name
version = _MODREV .. _SPECREV

dependencies = {
  'lua >= 5.1',
}

test_dependencies = {
  'lua >= 5.1',
}

source = {
  -- TODO: Replace <user>
  url = 'git://github.com/<user>/' .. package,
}

build = {
  type = 'builtin',
  -- TODO: Add runtime diretories here
  -- copy_directories = {
      -- 'doc',
      -- "plugin",
  -- },
}



