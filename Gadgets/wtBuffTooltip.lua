--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2015-07-13T11:42:28Z (lifeismystery)
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
