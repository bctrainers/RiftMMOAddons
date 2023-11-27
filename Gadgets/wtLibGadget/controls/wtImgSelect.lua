--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.9.4-beta
      Project Date (UTC)  : 2015-07-13T16:47:34Z
      File Modified (UTC) : 2015-07-13T08:46:59Z (lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate



WT.Control.ImgSelect = {}
WT.Control.ImgSelect_mt = 
{ 
	__index = function(tbl,name)
		if tbl.frameIndex[name] then return tbl.frameIndex[name] end
		if WT.Control.ImgSelect[name] then return WT.Control.ImgSelect[name] end  
		if WT.Control[name] then return WT.Control[name] end
		return nil  
	end 
}

local function UpdateTexture(frame, mediaId)
	local media = Library.Media.GetTexture(mediaId)
	frame:SetTexture(media.addonId, media.filename)
end

function WT.Control.ImgSelect.Create(parent, label, default, mediaTag, onchange)

	local control = UI.CreateFrame("Frame", WT.UniqueName("Control"), parent)
	control.frameIndex = getmetatable(control).__index
	setmetatable(control, WT.Control.ImgSelect_mt) 

	local tfValue = UI.CreateFrame("Text", WT.UniqueName("GadgetControlUnitSpecImgSelector_TextField"), control)
	tfValue:SetText(default or "")
	tfValue:SetWidth(200)
	tfValue:SetBackgroundColor(0.97,0.97,0.97,0.1)
	tfValue:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	tfValue:SetFontColor(1,0.97,0.84,1)
	tfValue:SetFontSize(14)
	--tfValue:SetFont(AddonId, "blank-Bold")

	local texTexture = UI.CreateFrame("Texture", WT.UniqueName("GadgetControlUnitSpecImgSelector_Texture"), control)
	texTexture:SetWidth(128)	
	texTexture:SetHeight(128)
	texTexture:SetBackgroundColor(0, 0, 0, 0)

	if label then
		local txtLabel = UI.CreateFrame("Text", WT.UniqueName("GadgetControlUnitSpecImgSelector_Label"), control)
		txtLabel:SetText(label)
		txtLabel:SetPoint("TOPLEFT", control, "TOPLEFT")
		tfValue:SetPoint("CENTERLEFT", txtLabel, "CENTERRIGHT", 8, 0)
		txtLabel:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		txtLabel:SetFontColor(1,0.97,0.84,1)
		txtLabel:SetFontSize(14)
		--txtLabel:SetFont(AddonId, "blank-Bold")		
	else
		tfValue:SetPoint("TOPLEFT", control, "TOPLEFT", 0, 0)
	end	
	texTexture:SetPoint("TOPLEFT", tfValue, "BOTTOMLEFT", 0, 2)

	local dropDownIcon = UI.CreateFrame("Texture", WT.UniqueName("GadgetControlUnitSpecImgSelector_Dropdown"), tfValue)
	dropDownIcon:SetTexture(AddonId, "img/wtDropDown.png")
	dropDownIcon:SetHeight(tfValue:GetHeight())
	dropDownIcon:SetWidth(tfValue:GetHeight())
	dropDownIcon:SetPoint("TOPLEFT", tfValue, "TOPRIGHT", -10, 0)

	local lMedia = Library.Media.FindMedia(mediaTag)
	local listMedia = {}
	for mediaId, media in pairs(lMedia) do
		table.insert(listMedia, { ["text"]=mediaId, ["value"]=mediaId })
	end

	local menu = WT.Control.Menu.Create(parent, listMedia, function(value) tfValue:SetText(value); UpdateTexture(texTexture, value); if onchange then onchange(tostring(value)) end; end, true)
	menu:SetPoint("TOPRIGHT", dropDownIcon, "BOTTOMCENTER")

	dropDownIcon:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self, h)
		menu:Toggle()
	end, "Event.UI.Input.Mouse.Left.Click")

	control.GetText = function() return tfValue:GetText() end
	control.SetText = 
		function(ctrl, value) 
			tfValue:SetText(tostring(value))
			UpdateTexture(texTexture, value) 
			if onchange then onchange(tostring(value)) end 
		end
		
	control:SetHeight(136)
		
	return control
			
end
