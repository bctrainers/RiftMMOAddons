
module(..., package.seeall)

--print('Loading ' .. _NAME)

require 'utils'
local Object = require('object').Object
local Array = require('array').Array
local Groups = require('groups').Groups
local Cell = require('cell').Cell

utils.openpackage(utils, getfenv())

local insert = table.insert
local concat = table.concat
local remove = table.remove
local format = string.format
local yield = coroutine.yield
local wrap = coroutine.wrap
local type = type
local unpack = unpack
local tonumber = tonumber


--[=[  Board object  ]=]--

local IGNORE = 5      -- position of ignore parameter in params list

commonparams = {
  [ 36] = {10, 2, 3},
  [ 81] = {10, 3},
  [144] = {16, 3, 4},
  [256] = {16, 4},
  [257] = {17, 4},
  empty = '.-_',
  ignore = ',;|%s',
}

local function ignorer(arg)
  if type(arg) == 'function' then return arg end
  arg = '[' .. (arg or commonparams.ignore) .. ']+'
  return function (data) return data:gsub(arg, '') end
end

function normalize(str, empty, zerovalues, ignore)
  if ignore then str = ignorer(ignore)(str) end
  str = str:lower()
  if zerovalues then str = str:gsub('0', zerovalues) end
  empty = escapemagic_pattern(empty or (commonparams.empty .. (zerovalues and '' or '0')))
  return (str:gsub('['..empty..']', '0'))
end



Board = Array:newmeta(1)

Board.tonumber = tonumber
Board.cell = Cell

function Board:new(spec, params)
  local is_str = type(spec) == 'string'
  if is_str then
    spec = ignorer(params and params[IGNORE])(spec)
  end
  params = params and params or spec and commonparams[#spec] or commonparams[81]
  assert(params, 'Could not find board parameters.')
  local o = self:_addsubspace(nil, self.dimension)
  o:init(params)
  if spec then
    if is_str then
      local base, empty, tonumber = self.base, self.empty, self.tonumber
      spec = explodestring(spec, function(c)
        return empty:find(c, 1, true) and 0 or tonumber(c, base) end)
--    else
--      spec = ipairs(spec)
    end
--    for i = 1,self.count do
--      o[i] = spec() or error('Error in board specification at position ' .. i)
--    local i = 0
      local solvable = true
    for i, v in ipairs(spec) do 
--      i = i + 1
      if v > 0 then solvable = o:assign(i, v) end
      if not solvable then break end
    end
    self.solvable = o:search(solvable)
  end
  return o
end

function Board:init(params)
  local base, p, q, empty = unpack(params)
  local range
  assert(base and p, 'Invalid board parameters.')
  q = q or p
  range = p * q
  if range ~= self.cell.range then self.cell = Cell:new({range = range}) end
  self:setfill(self.cell)
  self.p, self.q, self.base, self.range, self.count = p, q, base, range, range^2
  if not empty then
    if range < base then
      self.empty = '0' .. commonparams.empty
    else
      self.empty = commonparams.empty
      self.tonumber = function (c, b) return c == '0' and b or tonumber(c, b) end
    end
  end
  self.groups = Groups:new(p, q)
  self.linksets = self.groups:linksets()
  self.stacks = Array:new(1, function () return {} end)
end

function Board:push()
  local stacks = self.stacks
  for i = 1, self.count do
    insert(stacks[i], self[i])
    self[i] = self[i]:copy()
  end
end

function Board:pop()
  local stacks = self.stacks
  assert(next(stacks[1]), 'Attempted to pop empty stack.')
  for i = 1, self.count do self[i] = remove(stacks[i]) end
end

function Board:search(solvable)
  if solvable then
    if self:maxremaining() == 1 then return true end      -- solved!
    local _, i = self:minremaining()
    for v in self[i]:remains() do
      self:push()
      if self:search(self:assign(i, v)) then return true end
      self:pop()
    end
  end
  return false
end

function Board:assign(index, value)
  for r in self[index]:remains() do
    if r ~= value and not self:eliminate(index, r) then return false end
  end
  return true
end

function Board:eliminate(index, value)
  local cell = self[index]
  if not cell[value] then return true end        -- value already eliminated
  if not cell.choices then return false end      -- can not eliminate final value
  cell:remove(value)
  if not cell.choices then
    local v = cell.value
    for i in pairs(self.linksets[index]) do
      if not self:eliminate(i, v) then return false end
    end
  end
  for _, g in pairs(self.groups[index]) do
    local places = {}
    for i in pairs(g) do
      if self[i][value] then insert(places, i) end
    end
    if #places == 0 then
      return false
    elseif #places == 1 then
      if not self:assign(places[1], value) then return false end
    end
  end
  return true
end

function Board:minremaining()
  local remaining, index = self.range + 1, 0
  for i = 1,self.count do
    local r = self[i]:len()
    if 1 < r and r < remaining then remaining, index = r, i end
  end
  return remaining, index
end

function Board:maxremaining()
  local remaining, index = 0, 0
  for i = 1,self.count do
    local r = self[i]:len()
    if r > remaining then remaining, index = r, i end
  end
  return remaining, index
end

function Board:__tostring()
  local p, q, range = self.p, self.q, self.range
  local width = self:maxremaining() + 1
  local fmt = '%'..width..'s'
  local line = njoin(('-'):rep(width*q), p, '+')
  local i = 0
  local s = {}
  for r = 1,range do
    row = {}
    for c = 1,range do
      i = i + 1
      insert(row, format(fmt, tostring(self[i])))
      if c % q == 0 and c < range then insert(row, '|') end
    end
    insert(s, table.concat(row))
    if r % p == 0 and r < range then insert(s, line) end
  end
  insert(s, '')
  return concat(s, '\n')
end

function Board:export()
  if not self.solvable then return false end
  return concat(totable(imap(tostring, self:itervalues('s'))))
end


