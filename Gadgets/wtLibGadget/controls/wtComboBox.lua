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



WT.Control.ComboBox = {}
WT.Control.ComboBox_mt = 
{ 
	__index = function(tbl,name)
		if tbl.frameIndex[name] then return tbl.frameIndex[name] end
		if WT.Control.ComboBox[name] then return WT.Control.ComboBox[name] end  
		if WT.Control[name] then return WT.Control[name] end
		return nil  
	end 
}

function WT.Control.ComboBox.Create(parent, label, default, listItems, sort, onchange)

	local control = UI.CreateFrame("Frame", WT.UniqueName("Control"), parent)
	control.frameIndex = getmetatable(control).__index
	setmetatable(control, WT.Control.ComboBox_mt) 

	local tfValue = UI.CreateFrame("Text", WT.UniqueName("GadgetControlUnitSpecSelector_TextField"), control)
	tfValue:SetText(default or "")
	tfValue:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	tfValue:SetFontColor(1,0.97,0.84,1)
	tfValue:SetFontSize(14)
	tfValue:SetWidth(200)	
	tfValue:SetHeight(22)
	
	--tfValue:SetBackgroundColor(0.07,0.07,0.07,0.3)
	tfValue:SetBackgroundColor(0.97,0.97,0.97,0.1)

	if label then
		local txtLabel = UI.CreateFrame("Text", WT.UniqueName("GadgetControlUnitSpecSelector_Label"), control)
		txtLabel:SetText(label)
		txtLabel:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		txtLabel:SetFontColor(1,0.97,0.84,1)
		txtLabel:SetFontSize(14)
		txtLabel:SetPoint("TOPLEFT", control, "TOPLEFT")
		tfValue:SetPoint("CENTERLEFT", txtLabel, "CENTERRIGHT", 8, 0)
	else
		tfValue:SetPoint("TOPLEFT", control, "TOPLEFT", 0, 0)
	end	

	local dropDownIcon = UI.CreateFrame("Texture", WT.UniqueName("GadgetControlUnitSpecSelector_Dropdown"), tfValue)
	dropDownIcon:SetTexture(AddonId, "img/wtDropDown.png")
	dropDownIcon:SetHeight(tfValue:GetHeight())
	dropDownIcon:SetWidth(tfValue:GetHeight())
	dropDownIcon:SetPoint("TOPLEFT", tfValue, "TOPRIGHT", -10, 0)

	--local menu = WT.Control.Menu.Create(parent, listItems, function(value) tfValue:SetText(value) end, sort)
	local menu = WT.Control.Menu.Create(parent, listItems, 
	function(value) 
	control:SetText(value) 
	if WT.Gadget.CreateGadgetWindow.selected.gadgetConfig.gadgetType == "CastbarPresets" then WT.Control.UpdatePreview_Cast() end; 
	end, sort)
	control.listItems = listItems
	
	menu:SetPoint("TOPRIGHT", dropDownIcon, "BOTTOMCENTER")

	dropDownIcon:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self, h)
		menu:Toggle()
	end, "Event.UI.Input.Mouse.Left.Click")

	control.GetText = function() return tfValue:GetText() end
	control.SetText = 
		function(ctrl, value) 
			tfValue:SetText(tostring(value))
			if onchange then onchange(tostring(value)) end 
		end
		
	control:SetHeight(20)
		
	return control
			
end
