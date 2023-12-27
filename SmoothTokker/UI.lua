--[[
**   Smooth Tokker (RIFT addon) - UI.lua
--]]

local rift, privy = ...

local type = type
local pairs = pairs
local ipairs = ipairs
local assert = assert
local select = select
local unpack = unpack
local setmetatable = setmetatable
local insert = table.insert
local ceil = math.ceil
local max = math.max

require 'utils'
local irange = utils.irange
local imap = utils.imap
local totable = utils.totable

local setborder = Library.LibSimpleWidgets.SetBorder

local blue80 = privy.colors.blue80

local WidgetFactory = {}

function WidgetFactory:new(config)
  assert(config.type, "Required configuration field missing: 'type'")
  assert(config.id, "Required configureation field missing: 'id'")
  config.methods = config.methods or {}
  config.functions = config.functions or {}
  config.arguments = config.arguments or {}
  self.__index = self
  return setmetatable(config, self)
end

function WidgetFactory:__call(parent, ...)
  local widget = UI.CreateFrame(self.type, self.id:format(...), parent)
  for name, args in pairs(self.methods) do
    if type(args) == 'function' then
      widget[name](widget, args(widget, parent, ...))
    else
      widget[name](widget, unpack(args))
    end
  end
  for _, fn in ipairs(self.functions) do fn(widget, parent, ...) end
  for name, pos in pairs(self.arguments) do widget[name] = select(pos, ...) end
  return widget
end

local function fillgrid(grid, factory, rowrange, colrange, rowoffset, coloffset)
  rowoffset, coloffset = rowoffset or 0, coloffset or 0
  local r1, r2 = rowoffset + 1, rowoffset + rowrange
  local c1, c2 = coloffset + 1, coloffset + colrange
  for r = r1,r2 do
    grid:AddRow(totable(imap(function (c) return factory(grid, r, c) end, irange(c1, c2))))
  end
  return grid
end

local function makedivisibleby(d, n) return ceil(n / d) * d end

local function scalegridline(w)
  local scale = Inspect.Setting.Detail('displayUiScale').value
  return w/scale
end

local ui = {make = {}, cellarray = privy.cellarray}
privy.ui = ui

function ui:create()  --cellht, major, minor)
  local cellht = 40 * tokker_scale
  local minorgridline, majorgridline = scalegridline(1), cellht / 8

  local gridlinetotal = 2*majorgridline + 6*minorgridline
  local cellheight, cellwidth, fontsize = cellht, cellht * 7/10, cellht * 8/10
  local gridheight = makedivisibleby(5, 9*cellheight + gridlinetotal) -- 380
  local gridwidth = makedivisibleby(5, 9*cellwidth + gridlinetotal)   -- 270
  local baseheight, basewidth = gridheight * 6/5, gridwidth * 6/5
  local buttonheight, buttonwidth = cellheight, basewidth * 2/5
  local titleheight = 65
  local windowheight, windowwidth = baseheight + titleheight, basewidth

  local make = self.make
  local cellarray = self.cellarray

  function make.context() self.context = UI.CreateContext('tokker_Context') end

  local WindowFactory = WidgetFactory:new{
    type = "SimpleWindow",
    id = "tokker_SudokuWindow",
    methods = {
      SetTitle = {"Smooth Tokker"},
      SetHeight = {windowheight},
      SetWidth = {windowwidth},
      SetCloseButtonVisible = {true},
      SetVisible = {true},
    },
  }
  function make.window() self.window = WindowFactory(self.context) end

  local SolveButtonFactory = WidgetFactory:new{
    type = "RiftButton",
    id = "tokker_SolveButton",
    methods = {
      SetHeight = {buttonheight},
      SetWidth = {buttonwidth},
      SetPoint = function (_, parent) return 'CENTER', parent, .29, .92 end,
      SetText = function () return self.cellarray.active and 'SOLVE' or 'UNSOLVE' end,
    },
  }

  local ResetButtonFactory = WidgetFactory:new{
    type = 'RiftButton',
    id = 'tokker_ResetButton',
    methods = {
      SetHeight = {buttonheight},
      SetWidth = {buttonwidth},
      SetPoint = function (_, parent) return 'CENTER', parent, .71, .92 end,
      SetText = {'RESET'},
    },
  }
  function make.buttons()
    self.solvebutton = SolveButtonFactory(self.window)
    self.resetbutton = ResetButtonFactory(self.window)
  end
--[[
  local gridmethods = {}

  function gridmethods:Layout()
    local padding = self.padding
    for r, row in ipairs(self.rows) do
      if #row ~= 3 then print('Bad row length', r, #row) end
      if not self.rowflags[r] then
        for c, cell in ipairs(row) do
          if cell:GetHeight() ~= cellheight then
            print('Bad height', cell.row, cell.column, cell:GetHeight(), cellheight)
          end
          if cell:GetWidth() ~= cellwidth then
            print('Bad width', cell.row, cell.column, cell:GetWidth(), cellwidth)
          end
          cell:SetPoint('TOPLEFT', self, 'TOPLEFT', (c-1)*(cellwidth + padding), (r-1)*(cellheight + padding))
        end
        self.rowflags[r] = true
      end
    end
    self:SetWidth(3 * cellwidth + 2 * padding)
    self:SetHeight(#self.rows * cellheight + (#self.rows - 1) * padding)
  end
--]]

  local GridFactory = WidgetFactory:new{
    type = "SimpleGrid",
    id = "tokker_SudokuGrid",
    methods = {
      SetBackgroundColor = {blue80(.25)},
      SetCellPadding = {majorgridline},
      SetPoint = function (_, parent) return "TOPCENTER", parent, "TOPCENTER", 0, titleheight end,
    },
    functions = {
      function (obj) setborder('rounded', obj) end
    },
  }
  function make.grid()
    local grid = GridFactory(self.window)
--    grid.LayoutCells = gridmethods.LayoutCells
--    grid.Layout = gridmethods.Layout
    self.grid = fillgrid(grid, make.subgrid, 3, 3)
  end

  local SubgridFactory = WidgetFactory:new{
    type = "SimpleGrid",
    id = "tokker_SubGrid_%u_%u",
    methods = {
      SetBackgroundColor = {blue80(.1)},
      SetCellPadding = {minorgridline},
    },
    arguments = {
      row = 1,
      column = 2,
    },
  }
  function make.subgrid(parent, row, col)
    local sg = SubgridFactory(parent, row, col)
--    sg.LayoutCells = gridmethods.LayoutCells
--    sg.rowflags = {}
--    sg.Layout = gridmethods.Layout
    return fillgrid(sg, make.cell, 3, 3, 3*(row - 1), 3*(col - 1))
  end

  local CellFactory = WidgetFactory:new{
    type = "Text",
    id = "tokker_Cell_%u_%u",
    methods = {
      SetHeight = {cellheight},
      SetWidth = {cellwidth},
      SetBackgroundColor = {privy.cellcolors.default()},
      SetFontSize = {fontsize},
    },
    arguments = {
      row = 1,
      column = 2,
    },
  }
  cellarray.createcell = CellFactory

  function make.cell(parent, row, col)
    return cellarray:addcell(parent, row, col)
  end

  if not self.context then make.context() end
  make.window()
  make.buttons()
  make.grid()
end

