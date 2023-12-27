
module(..., package.seeall)

--print('Loading ' .. _NAME)

local chain = require('utils').chain
local Array = require('array').Array

local yield = coroutine.yield
local wrap = coroutine.wrap
local setmetatable = setmetatable


--[=[  Groups object  ]=]--

Groups = {}

function Groups:new(p, q)
  -- A board is a q x p grid of p x q regions.
  local rows, columns, regions = Array:new(2), Array:new(2), Array:new(3)
  local o = {rows = rows, columns = columns, regions = regions}
  local i, r, c = 0, 0, nil            -- cell index, row, and column counters
  for d1 = 1,q do                      -- for each row of regions
    for d2 = 1,p do  r=r+1; c=0        -- for each row *within* a region
      for d3 = 1,p do                  -- for each column of regions
        for d4 = 1,q do  c=c+1; i=i+1  -- for each column *within* a region
          rows[r][i] = true
          columns[c][i] = true
          regions[d1][d3][i] = true
          o[i] = {rows[r], columns[c], regions[d1][d3]}
  end end end end
  self.__index = self
  return setmetatable(o, self)
end

function Groups:all()
  return wrap(function()
    local iter = chain{
      self.rows:iter(1),
      self.columns:iter(1),
      self.regions:iter(1),
    }
    for v in iter do yield(v) end
  end)
end


function Groups:linksets()
  local sets = Array:new(2)
  for group in self:all() do
    for i in group:iterkeys() do     -- for each cell index in the group
      local set = sets[i]
      for j in group:iterkeys() do   -- add each index in the group to its linkset
        set[j] = true
  end end end
  for i = 1, #sets do                -- unlink each cell from itself
    sets[i][i] = nil
  end
  return sets
end
