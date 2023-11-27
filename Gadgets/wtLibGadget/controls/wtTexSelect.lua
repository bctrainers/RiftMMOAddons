--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.5.4
      Project Date (UTC)  : 2013-10-06T09:26:25Z
      File Modified (UTC) : 2013-09-14T09:22:53Z (Adelea)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate



WT.Control.TexSelect = {}
WT.Control.TexSelect_mt = 
{ 
	__index = function(tbl,name)
		if tbl.frameIndex[name] then return tbl.frameIndex[name] end
		if WT.Control.TexSelect[name] then return WT.Control.TexSelect[name] end  
		if WT.Control[name] then return WT.Control[name] end
		return nil  
	end 
}

local function UpdateTexture(frame, mediaId)
	local media = Library.Media.GetTexture(mediaId)
	frame:SetTexture(media.addonId, media.filename)
end

function WT.Control.TexSelect.Create(parent, label, default, mediaTag, onchange)

	local control = UI.CreateFrame("Frame", WT.UniqueName("Control"), parent)
	control.frameIndex = getmetatable(control).__index
	setmetatable(control, WT.Control.TexSelect_mt) 

	local tfValue = UI.CreateFrame("Text", WT.UniqueName("GadgetControlUnitSpecTexSelector_TextField"), control)
	tfValue:SetText(default or "")
	tfValue:SetWidth(200)
	tfValue:SetBackgroundColor(0.97,0.97,0.97,0.1)
	tfValue:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	tfValue:SetFontColor(1,0.97,0.84,1)
	tfValue:SetFontSize(14)	

	local texTexture = UI.CreateFrame("Texture", WT.UniqueName("GadgetControlUnitSpecTexSelector_Texture"), control)
	texTexture:SetWidth(200)	
	texTexture:SetHeight(24)
	texTexture:SetBackgroundColor(0, 0, 0, 1)

	if label then
		local txtLabel = UI.CreateFrame("Text", WT.UniqueName("GadgetControlUnitSpecTexSelector_Label"), control)
		txtLabel:SetText(label)
		txtLabel:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		txtLabel:SetFontColor(1,0.97,0.84,1)
		txtLabel:SetFontSize(14)
		txtLabel:SetPoint("TOPLEFT", control, "TOPLEFT")
		tfValue:SetPoint("CENTERLEFT", txtLabel, "CENTERRIGHT", 8, 0)
	else
		tfValue:SetPoint("TOPLEFT", control, "TOPLEFT", 0, 0)
	end	
	texTexture:SetPoint("TOPLEFT", tfValue, "BOTTOMLEFT", 0, 2)

	local dropDownIcon = UI.CreateFrame("Texture", WT.UniqueName("GadgetControlUnitSpecTexSelector_Dropdown"), tfValue)
	dropDownIcon:SetTexture(AddonId, "img/wtDropDown.png")
	dropDownIcon:SetHeight(tfValue:GetHeight())
	dropDownIcon:SetWidth(tfValue:GetHeight())
	dropDownIcon:SetPoint("TOPLEFT", tfValue, "TOPRIGHT", -10, 0)

	local lMedia = Library.Media.FindMedia(mediaTag)
	local listMedia = {}
	for mediaId, media in pairs(lMedia) do
		table.insert(listMedia, { ["text"]=mediaId, ["value"]=mediaId })
	end

	local TexMenu = WT.Control.TexMenu.Create(parent, listMedia, 
	function(value) 
	tfValue:SetText(value); 
	UpdateTexture(texTexture, value); 
	if onchange then onchange(tostring(value)) end; 
	end, true)
	TexMenu:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 170, -120)

	dropDownIcon:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self, h)
		TexMenu:Toggle()
	end, "Event.UI.Input.Mouse.Left.Click")

	control.GetText = function() return tfValue:GetText() end
	control.SetText = 
		function(ctrl, value) 
			tfValue:SetText(tostring(value))
			UpdateTexture(texTexture, value) 
			if onchange then onchange(tostring(value)) end 
		end
		
	control:SetHeight(46)
		
	return control
			
end
