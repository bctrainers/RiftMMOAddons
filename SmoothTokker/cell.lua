--[[
**   Smooth Tokker (RIFT addon) - cell.lua
--]]

local rift, privy = ...

local tonumber = tonumber
local assert = assert
local insert = table.insert
local concat = table.concat

require 'utils'
local totable = utils.totable
local tables = utils.tables
local iterstring = utils.iterstring
local chain = utils.chain
local imap = utils.imap
local njoin = utils.njoin

require 'object'
local itervalues = object.itervalues

local cellcolors = privy.cellcolors
local textcolors = privy.textcolors
local fonttag = textcolors.fonttag

local cellarray = totable(tables(9))
cellarray.active = true
privy.cellarray = cellarray


--[=[  TextCell  ]=]--

local TextCell = {}

function TextCell:new(r, c)
  local o = {}
  local row = tokker_cellvalues[r]
  function o:set(v) row[c] = v end
  function o:get() return row[c] end
  if tokker_holdvalues then
    local i = 9*(r - 1) + c
    o.hold = tokker_holdvalues:sub(i, i) == '1' and true or nil
  end
  self.__index = self
  return setmetatable(o, self)
end

function TextCell:freeze()
  if self:get() ~= '0' then
    self.hold = true
    return '1'
  else
    return '0'
  end
end

function TextCell:unfreeze()
  if self.hold then
    self.hold = nil
  else
    self:set('0')
  end
end

function TextCell:reset()
  self.hold = nil
  self:set('0')
end
--[[
function TextCell:__tostring()
  if self.hold then
    return '<font color="#7f7fff">' .. self:get() .. '</font>'
  else
    return self:get()
  end
end
--]]

--[=[  cellmethods  ]=]--

local cellmethods = {}

function cellmethods:set(c)
  tokker_cellvalues[self.row][self.column] = c
  self:SetText(c == '0' and '' or c)
end

function cellmethods:get()
  local c = self:GetText()
  return c == '' and '0' or c
end

function cellmethods:freeze()
  if self:GetText() ~= '' then
    self.hold = true
    self:SetBackgroundColor(cellcolors.hold())
    return '1'
  else
    return '0'
  end
end

function cellmethods:unfreeze()
  if self.hold then
    self.hold = nil
    self:SetBackgroundColor(cellcolors.default())
  else
    self:set('0')
  end
end

function cellmethods:focus()
  self:SetBackgroundColor(cellcolors.focus())
  self:SetEffectGlow(cellcolors.focusglow)
end

function cellmethods:defocus()
  self:SetBackgroundColor(cellcolors.default())
  self:SetEffectGlow(nil)
end

function cellmethods:reset()
  self.hold = nil
  self:SetBackgroundColor(cellcolors.default())
  self:SetEffectGlow(nil)
  self:set('0')
end


--[=[  cellevents  ]=]--

local cellevents = {}

function cellevents:KeyFocusGain()
  self:focus()
  cellarray.focus = self
end

function cellevents:KeyFocusLoss()
  self:defocus()
  cellarray.focus = nil
end

local keyhandlers = {
  Space = function (cell) cell:set('') end,
  Return = function (cell) cell:SetKeyFocus(false) end,
  Up = function (cell)
         local row = cell.row
         cellarray[row > 1 and row - 1 or 9][cell.column]:SetKeyFocus(true)
       end,
  Down = function (cell)
           local row = cell.row
           cellarray[row < 9 and row + 1 or 1][cell.column]:SetKeyFocus(true)
         end,
  Left = function (cell)
           local col = cell.column
           cellarray[cell.row][col > 1 and col - 1 or 9]:SetKeyFocus(true)
         end,
  Right = function (cell)
            local col = cell.column
            cellarray[cell.row][col < 9 and col + 1 or 1]:SetKeyFocus(true)
          end,
}

keyhandlers.w = keyhandlers.Up
keyhandlers.s = keyhandlers.Down
keyhandlers.a = keyhandlers.Left
keyhandlers.d = keyhandlers.Right


function cellevents:KeyDown(key)
  key = key:match('Numpad (%d)') or key
  if '0' <= key and key <= '9' then
    self:set(key)
  else
    local handler = keyhandlers[key]
    if handler then handler(self) end
  end
end

function cellevents:WheelForward()
  if cellarray.active then
    cellarray.defocus()
    local v = tonumber(self:get())
    self:set(v < 9 and tostring(v + 1) or '0')
  end
end

function cellevents:WheelBack()
  if cellarray.active then
    cellarray.defocus()
    local v = tonumber(self:get())
    self:set(v > 0 and tostring(v - 1) or '9')
  end
end

function cellevents:LeftClick()
  if cellarray.active then
    self:SetKeyFocus(true)
  end
end

function cellevents:RightClick()
  if cellarray.active then
    cellarray.defocus()
    self:set('0')
  end
end

function cellevents:MouseIn()
  if cellarray.active and cellarray.focus ~= self then
    self:SetEffectGlow(cellcolors.mouseoverglow)
  end
end

function cellevents:MouseOut()
  if cellarray.active and cellarray.focus ~= self then
    self:SetEffectGlow(nil)
  end
end

--[=[  cellarray  ]=]--

function cellarray:init()
  for r = 1, 9 do
    for c = 1, 9 do
      cellarray[r][c] = TextCell:new(r, c)
  end end
  cellarray.active = not tokker_holdvalues
end

local function _createcell(parent, r, c)
  error('Cells can not be added to the array before createfactories() has been called.', 2)
end

cellarray.createcell = _createcell

function cellarray:addcell(parent, r, c)
  local cell = self.createcell(parent, r, c)
  for name, handler in pairs(cellevents) do
    cell.Event[name] = handler
  end
  for name, method in pairs(cellmethods) do
    cell[name] = method
  end
  local v = self[r][c]:get()
  cell:SetText(v == '0' and '' or v)
  if self[r][c].hold then cell:freeze() end
  self[r][c] = cell
  return cell
end

function cellarray:load(str)
  assert(self.active, 'can not load inactive cellarray')
  assert(#str == 81, 'bad argument: incorrect length string')
  local itr = iterstring(str)
  for cell in chain(self) do cell:set(itr()) end
end

function cellarray:dump()
  local function get(cell) return cell:get() end
  return concat(totable(imap(get, chain(self))))
end

function cellarray:freeze()
  local holds = {}
  for cell in chain(self) do insert(holds, cell:freeze()) end
  tokker_holdvalues = concat(holds)
--  return self:dump()
end

function cellarray:revert()
  tokker_holdvalues = false
  for cell in chain(self) do cell:unfreeze() end
end

function cellarray:reset()
  cellarray:defocus()
  cellarray.active = true
  tokker_holdvalues = false
  for cell in chain(self) do cell:reset() end
end

function cellarray:defocus()
  local focus = cellarray.focus
  if focus then
    focus:SetKeyFocus(false)
    cellarray.focus = false
  end
end

function cellarray:torowstrings()
  local rowstrings = {}
  local spacer = njoin(('-'):rep(7), 3, '+')
  for r = 1, 9 do
    local row = self[r]
    local t = {}
    for c = 1, 9 do
      local cell = row[c]
      local v = cell:get()
      v = v > '0' and v or fonttag('0', textcolors.empty)
      v = cell.hold and fonttag(v, textcolors.hold) or v
      insert(t, v)
      if c % 3 ~= 0 then insert(t, ' ')
      elseif c < 9 then insert(t, ' | ') end
    end
    insert(rowstrings, concat(t))
    if r == 3 or r == 6 then insert(rowstrings, spacer) end
  end
  return rowstrings
end

