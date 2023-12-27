--[[
**   Smooth Tokker (RIFT addon) - main.lua
--]]

--[=[  The RIFT Environment  ]=]--
local rift, privy = ...
local toc = rift.toc


--[=[  Declarations  ]=]--
local tonumber = tonumber
local ipairs = ipairs
local error = error
local insert = table.insert
local remove = table.remove
local concat = table.concat
local format = string.format
local min = math.min
local floor = math.floor

--[=[  Imports  ]=]--
local setborder = Library.LibSimpleWidgets.SetBorder

local sudoku = require 'sudoku'    -- require() defined as global in planetouchedmodules.lua in libsudoku

local utils = require 'utils'
local constant = utils.constant
local iterstring = utils.iterstring
local explodestring = utils.explodestring
local split = utils.split
local trim = utils.trim
local strip = utils.strip
local cut = utils.cut
local irange = utils.irange
local totable = utils.totable
local inittable = utils.inittable
local map = utils.map
local imap = utils.imap
local chain = utils.chain

--[=[  Saved Variables  ]=]--

--Command.Event.Attach(

insert(Event.Addon.SavedVariables.Load.End, {function(id)
  if id == toc.Identifier then
    if not tokker_cellvalues then
      tokker_cellvalues = {}
      for i = 1, 9 do tokker_cellvalues[i] = inittable(9, '0') end
    end
    if tokker_holdvalues == nil then
      tokker_holdvalues = false
    end
    if not tokker_position then
      tokker_position = {300, 120}
    end
    if tokker_autoprint == nil then
      tokker_autoprint = false
    end
    if not tokker_scale then
      tokker_scale = 1
    end
    privy.cellarray:init()
--    print('Variables initialized')
  end
end, toc.Identifier, 'tokker_InitializeFromSavedVariables'})


--[=[  Interface  ]=]--

local ui = privy.ui
local cellarray = ui.cellarray
local window, solvebutton, resetbutton, grid
local slashcommands_single, slashcommands_series, slash_command

local function setuivars(ui)
  window = ui.window
  solvebutton = ui.solvebutton
  resetbutton = ui.resetbutton
  grid = ui.grid
end

local function print_grid_state(channel)
  local strings = cellarray:torowstrings()
  channel = (channel == nil or channel == '') and 'general' or channel
  Command.Console.Display(channel, false, 'Current grid state:', false)
  for _, s in ipairs(strings) do
    Command.Console.Display(channel, true, s, true)
  end
end

local function savewindowposition() tokker_position = {window:GetLeft(), window:GetTop()} end
local function defocus() cellarray:defocus() end


--[=[  Slash Commands  ]=]--

local testgrids = {
  '003020600900305001001806400008102900700000008006708200002609500800203009005010300',
  sudoku.normalize('4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......'),
}

local function slash_test(n)
  n = tonumber(n)
  n = n and min(n, #testgrids) or 1
  cellarray:load(testgrids[n])
end

local function slash_autoprint(args)
  if tokker_autoprint then
    tokker_autoprint = false
    Command.Console.Display('general', false, 'Autoprint: off', false)
  else
    tokker_autoprint = trim(args)
    Command.Console.Display(
      tokker_autoprint == '' and 'general' or tokker_autoprint,
      false, 'Autoprint: on', false)
  end
end

local function slash_scale(arg)
  local scale = tonumber(arg)
  if not scale then
    error('could not set display scale: expected number not ' .. arg)
  elseif 0.5 <= scale and scale <= 2 then
    tokker_scale = arg
    Command.Console.Display('general', false, 'Scale set to: ' .. arg, false)
    if window then Command.Console.Display('general', false,
      '<font color="#7f5fff">/reloadui</font> required for new scale to take effect.', true) end
  else
    error('scale out of range, must be between 0.5 and 2.0')
  end
end

local function slash_value(args)
  local row, col, v = args:match('(%d)%s*(%d)%s*(%d?)')
  assert(row and col and row > '0' and col > '0', 'could not find cell coordinates for value command')
  cellarray[tonumber(row)][tonumber(col)]:set(v or '0')
end

local assignargspattern = '^(%d)%s*(' .. ('%d?'):rep(9) .. ')$'

local function assignargs(str)
  local index, values = str:match(assignargspattern)
  if not index then error('invalid command parameters') end
  return tonumber(index), chain{iterstring(values), constant('0', 9 - #values)}
end

local function slash_row(args)
  local index, values = assignargs(args)
  local row = cellarray[index]
  for c = 1, 9 do row[c]:set(values()) end
end

local function slash_column(args)
  local index, values = assignargs(args)
  for r = 1, 9 do cellarray[r][index]:set(values()) end
end

local function slash_region(args)
  local index, values = assignargs(args)
  local offsetr = 3 * floor((index-1) / 3)
  local offsetc = 3 * ((index-1) % 3)
  for r = offsetr + 1, offsetr + 3 do
    for c = offsetc + 1, offsetc + 3 do
      cellarray[r][c]:set(values())
    end
  end
end

local function display(text)
  Command.Console.Display('general', true, text, true)
end

local function slash_help(topic)
  local text = toc.helptext
  local tc = privy.textcolors

  display(tc.fonttag(text.header, tc.header))

  if topic == 'config' then
    for _, line in ipairs(text.config) do display(line) end
  elseif topic == 'text' then
    for _, line in ipairs(text.text_intro) do display(line) end
    display('\n')
    for _, cmd in ipairs(text.text_commands) do
      display(format(text.command, unpack(cmd)))
    end
    display('\n')
    for _, line in ipairs(text.text_series) do display(line) end
  elseif topic == 'commands' then
    display('Full command list:')
    for cmd in chain{text.basic_commands, text.config_commands, text.text_commands, text.help_topics} do
      display(format(text.command, unpack(cmd)))
    end
  else
    for _, line in ipairs(text.basic) do display(line) end
    for _, line in ipairs(text.mouse) do display(line) end
    display('')
    display('Help topics:')
    for _, topic in ipairs(text.help_topics) do
      display(format(text.command, unpack(topic)))
    end
  end
end

local function slash_help_config() return slash_help('config') end
local function slash_help_text() return slash_help('text') end
local function slash_help_commands() return slash_help('commands') end

local function slash_solve()
  if cellarray.active then
    cellarray:defocus()
    local solution = sudoku.Board:new(cellarray:dump()):export()
    if solution then
      cellarray:freeze()
      cellarray:load(solution)
      cellarray.active = false
      if solvebutton then solvebutton:SetText('UNSOLVE') end
    else
      Command.Console.Display('general', false, 'No solution is possible for current grid.', false)
      cellarray:revert()
    end
  else
    cellarray.active = true
    cellarray:revert()
    if solvebutton then solvebutton:SetText('SOLVE') end
  end
end

local function slash_reset()
  cellarray.active = true
  cellarray:reset()
  if solvebutton then solvebutton:SetText('SOLVE') end
end

local function slash_print(args)
  local channel, command, oops = unpack(map(trim, split(args, ',')))
  if oops then error('invalid arguments') end
  if command and command ~= '' then slash_command(nil, command) end
  if not tokker_autoprint then print_grid_state(channel) end
end
--[[
local function slash_print_comma(args)
  return slash_print(' ,' .. args)
end
--]]
local function slash_visibility() window:SetVisible(not window:GetVisible()) end

local function createui()
  slashcommands_single[''] = slash_visibility
  ui:create()  --40, 5, 1)
  setuivars(ui)
  window.Event.Move = savewindowposition
  solvebutton.Event.LeftPress = slash_solve
  resetbutton.Event.LeftPress = slash_reset
  window:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', tokker_position[1], tokker_position[2])
end
--[[
slashcommands = {
  [''] = createui,
  autoprint = slash_autoprint, a = slash_autoprint,
  column = slash_column,       c = slash_column,
  region = slash_region,       g = slash_region,
  help = slash_help,           h = slash_help,
--  info = slash_info,           i = slash_info,
--  mode = slash_mode,           m = slash_mode,
--  open = slash_open,           o = slash_open,
  print = slash_print,         p = slash_print,
  ['print,'] = slash_print_comma,    ['p,'] = slash_print_comma,
  reset = slash_reset,
  row = slash_row,             r = slash_row,
  solve = slash_solve,         s = slash_solve,
  testgrid = slash_test,
  unsolve = slash_solve,       u = slash_solve,
}
--]]
slashcommands_single = {
  [''] = createui,
  autoprint = slash_autoprint, a = slash_autoprint,
  help = slash_help,           h = slash_help, f = slash_help_config, t = slash_help_text, m = slash_help_commands,
  scale = slash_scale,
  testgrid = slash_test,
}

slashcommands_series = {
  column = slash_column,       c = slash_column,
  region = slash_region,       g = slash_region,
  print = slash_print,         p = slash_print,
  row = slash_row,             r = slash_row,
  solve = slash_solve,         s = slash_solve,
  unsolve = slash_solve,       u = slash_solve,
  value = slash_value,         v = slash_value,
  reset = slash_reset,
}

function slash_command(_, param)
  if param == nil then error('Something went wrong. nil should not be a possible argument.') end
  local commands = map(trim, split(param, ','))
  local success, errmsg
  if #commands == 0 then
    success, errmsg = pcall(slashcommands_single[''])
  elseif #commands == 1 then
    local command, args = cut(commands[1])
    local handler = slashcommands_single[command] or slashcommands_series[command]
    if handler then
      success, errmsg = pcall(handler, args)
    else
      success, errmsg = false, 'requested command does not exist: ' .. command
    end
  else
    local command, args, handler
    for i, str in ipairs(commands) do
      command, args = cut(str)
      handler = slashcommands_series[command]
      if handler then
        success, errmsg = pcall(handler, args)
      else
        success, errmsg = false, 'requested operation is not a series command: ' .. command
      end
      if not success then
        errmsg = format('(command series failed on command #%d) %s', i, errmsg)
        break
      end
    end
  end
  if success then
    if tokker_autoprint and not (window and window:GetVisible()) then
      print_grid_state(tokker_autoprint)
    end
  else
    Command.Console.Display('general', false, 'error: ' .. errmsg, false)
  end
end

Command.Event.Attach(Command.Slash.Register("tokker"), slash_command, "Slash command")

Command.Event.Attach(Event.Addon.Load.End, function(_, id)
  if id == toc.Identifier then
    local tc = privy.textcolors
    local ft = tc.fonttag
    local cmd1, cmd2 = ft('/tokker', tc.command), ft('/tokker help', tc.command)
    Command.Console.Display('general', true,
      ft(format('Hello from Smooth Tokker! %s opens the addon window and %s brings up usage information.', cmd1, cmd2), tc.hello),
      true)
  end
end, 'tokker_Loaded')


