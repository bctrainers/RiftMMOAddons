
module(..., package.seeall)

--print('Loading ' .. _NAME)

local inittable = require('utils').inittable

local insert = table.insert
local concat = table.concat
local yield = coroutine.yield
local wrap = coroutine.wrap


--[=[  Cell object  ]=]--


Cell = {range = 9}

function Cell:new(v)
  local o
  v = v or 0
  if type(v) == 'table' then
    o = v
--    o.__tostring = self.__tostring
  else
    if v > 0 then
      o = {value = v, v = true, choices = false}
    else
      o = inittable(self.range, true)
      o.choices = self.range
    end
  end
  self.__index = self
  return setmetatable(o, self)
end

function Cell:copy()
  local m = getmetatable(self)
  if self.value then return m:new(self.value) end
  local o = m:new()
  for n, bool in ipairs(self) do
    if not bool then o:remove(n) end
  end
  return o
end

function Cell:len()
  return self.choices or 1
end

function Cell:assign(v)
  local remains = {}
  self[v] = false
  for n in self:remains() do
    self[n] = false
    insert(remains, n)
  end
  self[v] = true
  self.value = v
  self.choices = false
  return utils.itervalues(remains, 'a')
end

function Cell:remains()
  return wrap(function ()
    if self.choices then
      for k, v in ipairs(self) do
        if v then yield(k)
      end end
    else
      yield(self.value)
end end) end

function Cell:remove(v)
  if not v or not self[v] then return self:len() end
  if self.value then return false end
  self[v] = false
  local c = self.choices - 1
  if c > 1 then
    self.choices = c
  else
    self.value = self:remains()()
    self.choices = false
  end
  return c
end

function Cell:__tostring()
  if self.choices then
    local s = {}
    for v in self:remains() do insert(s, v) end
    return concat(s)
  elseif self.value then
    return tostring(self.value)
  else
    return 'Cell (or descendant)'
  end
end

