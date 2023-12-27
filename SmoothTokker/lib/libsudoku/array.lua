
module(..., package.seeall)

--print('Loading ' .. _NAME)

require 'object'
local Object = object.Object
local itervalues = object.itervalues

local insert = table.insert
local yield = coroutine.yield
local wrap = coroutine.wrap
local floor = math.floor
local type = type
local getmetatable = getmetatable
local setmetatable = setmetatable

--[=[  Array type  ]=]--

local function createfill(default, static)
  if not static then
    local typ = type(default)
    if typ == 'table' then
      return function(...) return default:new(...) end
    elseif typ == 'function' then
      return default
  end end
  return function (v) return v == nil and default or v end
end

Array = Object:new()

function Array:newmeta(dimension, default, static)
  dimension = dimension or 1
  local m = {dimension = dimension,
             fill = createfill(default, static),
             __index = self.subspace__index,
             __newindex = self.subspace__newindex}
  self.__index = self
  return setmetatable(m, self)
end

function Array:new(dimension, default, static)
  local m = self:newmeta(dimension, default, static)
  return m:_addsubspace(nil, m.dimension)
end

function Array:setfill(default, static)
  self.fill = createfill(default, static)
end

function Array:_addsubspace(parent, dimension, o)
  o = setmetatable(o or {}, self)
  self[o] = {parent = parent,
             dimension = dimension > 1 and dimension or nil}
  return o
end

function Array:subspace__index(k)
  local m = getmetatable(self)
  if type(k) == 'number' and k == floor(k) then
    local dmn = m[self].dimension
    local v = dmn and m:_addsubspace(self, dmn - 1) or m.fill()
    rawset(self, k, v)
    return v
  end
  return m[k]
end

function Array:subspace__newindex(k, v)
  local m = getmetatable(self)
  if type(k) == 'number' and k == floor(k) then
    if v ~= nil then
      if m[self].dimension then error('Can not assign array subspace.', 2) end
      v = m.fill(v)
    end
    rawset(self, k, v)
  else
    m[k] = v
  end
end

function Array:__call(i, ...)
  local dmn = self[self].dimension or 1
  local subsp = self
  local arg = 1
  while dmn > 1 do
    subsp = subsp[i]
    assert(subsp, 'Subspace not found.')
    i = select(arg, ...)
    arg = arg + 1
    dmn = dmn - 1
  end
  local v = self._fill(select(arg, ...))
  rawset(subsp, i, v)
  return v
end

function Array:iter(dmn, seq)
  dmn = dmn or 0
  local arraydmn = self.dimension
  assert(arraydmn >= dmn and dmn >= -arraydmn, 'Dimension out of range.')
  if dmn < 0 then dmn = arraydmn + dmn end
  seq = seq == false and 'n' or (seq == true or seq == nil) and 's' or seq
  return wrap(function()
    local stack = Object:new{itervalues({self}, seq)}
    local i = arraydmn
    while i <= arraydmn do
      if i == dmn then
        for v in stack:remove() do yield(v) end
        i = i + 1
      else
        local v = stack[#stack]()
        if v then
          stack:insert(v:itervalues(seq))
          i = i - 1
        else
          stack:remove()
          i = i + 1
  end end end end)
end

