--[[
**   libsudoku (extension for inclusion in RIFT addon) - coda.lua
--]]

local rift, privy = ...

require 'sudoku'

if sudoku and sudoku.Board and sudoku.Board.export then
  Command.Console.Display('general', false, 'libsudoku loaded successfully', false)
end
