--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.5.1
      Project Date (UTC)  : 2014-01-27T12:31:38Z
      File Modified (UTC) : 2012-08-07T01:23:40Z (Wildtide)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


local tooltip = nil

function data.ShowBuffTooltip(unitSpec, buffId)
	if buffId then
		tooltipIcon = buffId
		Command.Tooltip(unitSpec, buffId)
	end
end

function data.HideBuffTooltip(buffId)
	if tooltipIcon == buffId then Command.Tooltip(nil) end
end
