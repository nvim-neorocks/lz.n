local keys = require('lz.n.handler.keys')

describe('keys', function()
  it('parses ids correctly', function()
    local tests = {
      { '<C-/>', '<c-/>', true },
      { '<C-h>', '<c-H>', true },
      { '<C-h>k', '<c-H>K', false },
    }
    for _, test in ipairs(tests) do
      if test[3] then
        assert.same(keys.parse(test[1]).id, keys.parse(test[2]).id)
      else
        assert.is_not.same(keys.parse(test[1]).id, keys.parse(test[2]).id)
      end
    end
  end)
end)
