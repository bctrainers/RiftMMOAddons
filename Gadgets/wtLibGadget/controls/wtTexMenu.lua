--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.5.4
      Project Date (UTC)  : 2013-10-06T09:26:25Z
      File Modified (UTC) : 2013-10-01T06:37:08Z (lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

local ctxTexMenu = UI.CreateContext("wtTexMenu")
ctxTexMenu:SetStrata("menu")

	
WT.Control.TexMenu = {}
WT.Control.TexMenu_mt = 
{ 
	__index = function(tbl,name)
		if tbl.frameIndex[name] then return tbl.frameIndex[name] end
		if WT.Control.TexMenu[name] then return WT.Control.ComboBox[name] end  
		if WT.Control[name] then return WT.Control[name] end
		return nil  
	end 
}

local currTexMenu = false

local function OnClickOutside()
	if currTexMenu then
		currTexMenu:Hide()
	end
end

local catchAllClicks = UI.CreateFrame("Frame", WT.UniqueName("TexMenu"), ctxTexMenu)
catchAllClicks:SetLayer(10000)
catchAllClicks:SetVisible(false)
catchAllClicks:SetAllPoints(UIParent)
catchAllClicks:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self, h)
WT.Utility.ClearKeyFocus(catchAllClicks)
		OnClickOutside()
	end, "Event.UI.Input.Mouse.Left.Click")
catchAllClicks:EventAttach(Event.UI.Input.Mouse.Right.Click, function(self, h)
WT.Utility.ClearKeyFocus(catchAllClicks)
		OnClickOutside()
	end, "Event.UI.Input.Mouse.Right.Click")

	
local function TexMenuItemClicked(TexMenu, itemIndex)
	local clicked = TexMenu.items[itemIndex]
	local item = clicked.TexMenuItem
	if type(item) == "table" then
		value = item.value or item.text
		if type(item.value) == "function" then item.value(item.text) end 
	else
		value = item
	end			
	if TexMenu.callback then TexMenu.callback(value) end
end

local function LoadItems(control, listItems)

	local last = nil
	local maxWidth = 0

	if not control.items then control.items = {} end
	for i,item in ipairs(control.items) do item:SetVisible(false) end

	for i,v in ipairs(listItems) do
	
		local txtOption = control.items[i]
		
		if not txtOption then 
			txtOption = UI.CreateFrame("Text", WT.UniqueName("TextureName"), control) 
			txtOption:SetPoint("TOPLEFT", frameScrollAnchor, "TOPLEFT", 0, 0)
			txtOption:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
			txtOption:SetFontColor(1,0.97,0.84,1)
			txtOption:SetFontSize(14)
			--txtOption:SetFont(AddonId, "blank-Bold")		

			txtOption:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self, h)
				TexMenuItemClicked(control, i)
			end, "Event.UI.Input.Mouse.Left.Click")

			table.insert(control.items, txtOption)
		end

		txtOption:SetVisible(true)

		txtOption.TexMenuItem = v
		if type(v) == "table" then
			txtOption:SetText(v.text or v.value)
		else
			txtOption:SetText(v)
		end
		local w = txtOption:GetWidth()
		if w > maxWidth then maxWidth = w end 
		if not last then
			txtOption:SetPoint("TOPLEFT", frameScrollAnchor, "TOPLEFT", 4, 4)
		else
			txtOption:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, 2)
		end

		last = txtOption
	end

	if last then	
		local bottom = last:GetBottom() + 5 
	end
	control:SetHeight(590)
	control:SetWidth(maxWidth + 20)

end
			
function WT.Control.TexMenu.Create(parent, listItems, callback, sort)

	local sorted = sort
	if sorted == nil then sorted = false end

	if sort then
		table.sort(listItems, 
			function(a,b)
				 local aVal = a
				 local bVal = b
				 if type(aVal) == "table" then aVal = aVal.text end
				 if type(bVal) == "table" then bVal = bVal.text end
				 return aVal < bVal
			end)
	end
	
	
	local control = UI.CreateFrame("Mask", WT.UniqueName("TexMenu"), parent)
	control.frameIndex = getmetatable(control).__index
	setmetatable(control, WT.Control.TexMenu_mt) 
	control:SetLayer(10001)
	control:SetVisible(false)
	control:SetBackgroundColor(0.07,0.07,0.07,0.85)
	control.callback = callback	
		
	local frameScrollAnchor = UI.CreateFrame("Frame", "WTGadgetScrollAnchorTexture", control)
	frameScrollAnchor:SetPoint("TOPLEFT", control, "TOPLEFT", 0, 0)

	local typeListScrollbar = UI.CreateFrame("RiftScrollbar", "WTGadgetTypeScrollTexture", control)

	typeListScrollbar:SetPoint("TOPRIGHT", control, "TOPRIGHT", -1, 1)
	typeListScrollbar:SetPoint("BOTTOM", control, "BOTTOM", nil, -1)
	typeListScrollbar:EventAttach(Event.UI.Scrollbar.Change, function(self, h)
	     frameScrollAnchor:SetPoint("TOPLEFT", control, "TOPLEFT", 0, -typeListScrollbar:GetPosition())
	end, "Event.UI.Scrollbar.Change")
		
	control:EventAttach(Event.UI.Input.Mouse.Wheel.Forward, function(self, h) typeListScrollbar:Nudge(-40) end, "Event.UI.Input.Mouse.Wheel.Forward")
	control:EventAttach(Event.UI.Input.Mouse.Wheel.Back, function(self, h) typeListScrollbar:Nudge(40) end, "Event.UI.Input.Mouse.Wheel.Back")
		
	
	local value = nil

	control.items = {}

	local last = nil
	local maxWidth = 0
	local notselected = nil
	
	for i,v in ipairs(listItems) do
		local txtOption = UI.CreateFrame("Text", WT.UniqueName("TextureName"), control)
		txtOption:SetPoint("TOPLEFT", frameScrollAnchor, "TOPLEFT", 0, 0)
		txtOption:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		txtOption:SetFontColor(1,0.97,0.84,1)
		txtOption:SetFontSize(14)
		--txtOption:SetFont(AddonId, "blank-Bold")
		txtOption.TexMenuItem = v
		local selected = i
		
        if notselected == nil then  notselected = selected end
		
		if type(v) == "table" then
			txtOption:SetText(v.text or v.value)
		else
			txtOption:SetText(v)
		end
		local w = txtOption:GetWidth()
		if w > maxWidth then maxWidth = w end 
		if not last then
			txtOption:SetPoint("TOPLEFT", frameScrollAnchor, "TOPLEFT", 4, 4)
		else
			txtOption:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, 2) 
		end
		
		function keyDown (self, h, key)
			if(key == "Down") then
				selected = math.min(selected + 1, #listItems)
				TexMenuItemClicked(control,selected)
				typeListScrollbar:NudgeDown()
				control.items[selected]:SetWidth(maxWidth)
				control.items[selected - 1]:SetBackgroundColor(0, 0, 0, 0)
				control.items[selected]:SetBackgroundColor(0.9, 0, 0.9, 0.2)
			elseif(key == "Up") then			
				selected = math.max(1, selected - 1)
				TexMenuItemClicked(control,selected)
				typeListScrollbar:NudgeUp()
				control.items[selected]:SetWidth(maxWidth)
				control.items[selected + 1]:SetBackgroundColor(0, 0, 0, 0)
				control.items[selected]:SetBackgroundColor(0.9, 0, 0.9, 0.2)
			else 
				return
			end	
		end
		
		txtOption:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self, h)
				TexMenuItemClicked(control,selected)
				control.items[selected]:SetKeyFocus(true)
				control.items[selected]:SetWidth(maxWidth)
				control.items[notselected]:SetBackgroundColor(0, 0, 0, 0)
				control.items[selected]:SetBackgroundColor(0.9, 0, 0.9, 0.2)
				notselected = i
		end, "Event.UI.Input.Mouse.Left.Click")	
		
	    txtOption:EventAttach(Event.UI.Input.Key.Down, keyDown, "")		
		txtOption:EventAttach(Event.UI.Input.Key.Repeat, keyDown, "")	
		
		last = txtOption
		table.insert(control.items, txtOption)
	end

	
	local bottom = last:GetBottom() + 5 
	control:SetHeight(590)
	control:SetWidth(maxWidth + 20)
	
	typeListScrollbar:SetRange(0, bottom - 590)	
			
	TopBorder = UI.CreateFrame("Frame", "TopBorder", control)
	TopBorder:SetBackgroundColor(0,0,0,1)
	TopBorder:SetLayer(10002)
	TopBorder:ClearAll()
	TopBorder:SetPoint("BOTTOMLEFT", control, "TOPLEFT", -2, -590)
	TopBorder:SetPoint("BOTTOMRIGHT", control, "TOPRIGHT", 2, 590)
	TopBorder:SetHeight(2)
				  
	BottomBorder = UI.CreateFrame("Frame", "BottomBorder", control)
	BottomBorder:SetBackgroundColor(0,0,0,1)
	BottomBorder:SetLayer(10002)
	BottomBorder:ClearAll()
	BottomBorder:SetPoint("TOPLEFT", control, "BOTTOMLEFT", -2, 590)
	BottomBorder:SetPoint("TOPRIGHT", control, "BOTTOMRIGHT",2, -590)
	BottomBorder:SetHeight(2)
				  
	leftBorder = UI.CreateFrame("Frame", "LeftBorder", control)
	leftBorder:SetBackgroundColor(0,0,0,1)
	leftBorder:SetLayer(10002)
	leftBorder:ClearAll()
	leftBorder:SetPoint("TOPRIGHT", control, "TOPLEFT", -maxWidth + 20, -2)
	leftBorder:SetPoint("BOTTOMRIGHT", control, "BOTTOMLEFT", maxWidth + 20, 2)
	leftBorder:SetWidth(2)
				  
	rightBorder = UI.CreateFrame("Frame", "RightBorder", control)
	rightBorder:SetBackgroundColor(0,0,0,1)
	rightBorder:SetLayer(10002)
    rightBorder:ClearAll()
	rightBorder:SetPoint("TOPLEFT", control, "TOPRIGHT", maxWidth + 20, -2)
	rightBorder:SetPoint("BOTTOMLEFT", control, "BOTTOMRIGHT", -maxWidth -20, 2)
	rightBorder:SetWidth(2)			
	
	control.GetValue = function() return value end

	control.Show = 
		function() 
			if currTexMenu then currTexMenu:Hide() end 
			catchAllClicks:SetParent(control:GetParent())
			catchAllClicks:SetVisible(true) 
			currTexMenu = control 
			WT.FadeIn(control, 0.2) -- fade in
			if control.OnOpen then control:OnOpen() end
		end
		
	control.Hide = 
		function() 
			control:SetVisible(false)
			catchAllClicks:SetVisible(false)
			control:SetKeyFocus(true)
			control:SetKeyFocus(false)		
			if control == currTexMenu then
				currTexMenu = false
			end 
			WT.FadeOut(control, 0.2) -- fade out
			if control.OnClose then 
			control:OnClose() 
			end
		end

	control.Toggle = 
		function() 
			if control == currTexMenu then
				control.Hide()
			else
				control.Show()
			end 
		end
		
	control.SetItems =
		function(control, itemList)
			LoadItems(control, itemList)
		end
	return control
end