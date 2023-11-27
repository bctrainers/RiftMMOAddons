--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2013-01-04T22:17:01Z (Wildtide)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


WT.Control.MacroSet = {}
WT.Control.MacroSet_mt = 
{ 
	__index = function(tbl,name)
		if tbl.frameIndex[name] then return tbl.frameIndex[name] end
		if WT.Control.MacroSet[name] then return WT.Control.MacroSet[name] end  
		if WT.Control[name] then return WT.Control[name] end
		return nil  
	end 
}

function WT.Control.MacroSet.Create(parent, label)

	local control = UI.CreateFrame("Frame", WT.UniqueName("Control"), parent)
	control.frameIndex = getmetatable(control).__index
	setmetatable(control, WT.Control.MacroSet_mt) 

	local btnClick = UI.CreateFrame("RiftButton", "btnMacroSet", control)
	btnClick:SetText(label)
	btnClick:SetPoint("TOPLEFT", control, "TOPLEFT")

	control:SetHeight(20)
		
	return control		
end
