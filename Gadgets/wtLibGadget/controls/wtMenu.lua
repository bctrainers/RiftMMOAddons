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

local ctxMenu = UI.CreateContext("wtMenu")
ctxMenu:SetStrata("menu")

WT.Control.Menu = {}
WT.Control.Menu_mt = 
{ 
	__index = function(tbl,name)
		if tbl.frameIndex[name] then return tbl.frameIndex[name] end
		if WT.Control.Menu[name] then return WT.Control.ComboBox[name] end  
		if WT.Control[name] then return WT.Control[name] end
		return nil  
	end 
}

local currMenu = false

local function OnClickOutside()
	if currMenu then
		currMenu:Hide()
	end
end

local catchAllClicks = UI.CreateFrame("Frame", WT.UniqueName("Menu"), ctxMenu)
catchAllClicks:SetLayer(10000)
catchAllClicks:SetVisible(false)
catchAllClicks:SetAllPoints(UIParent)
catchAllClicks:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self, h)
		OnClickOutside()
	end, "Event.UI.Input.Mouse.Left.Click")
catchAllClicks:EventAttach(Event.UI.Input.Mouse.Right.Click, function(self, h)
		OnClickOutside()
	end, "Event.UI.Input.Mouse.Right.Click")

local function MenuItemClicked(menu, itemIndex)
	local clicked = menu.items[itemIndex]
	local item = clicked.menuItem
	if type(item) == "table" then
		value = item.value or item.text
		if type(item.value) == "function" then item.value(item.text) end 
	else
		value = item
	end			
	if menu.callback then menu.callback(value) end
	menu.Hide()
end

local function LoadItems(control, listItems)

	local last = nil
	local maxWidth = 0

	if not control.items then control.items = {} end
	for i,item in ipairs(control.items) do item:SetVisible(false) end

	for i,v in ipairs(listItems) do
	
		local txtOption = control.items[i]
		
		if not txtOption then 
			txtOption = UI.CreateFrame("Text", WT.UniqueName("GadgetControlMenuOption"), control.dropDownBackground) 
			txtOption:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
			txtOption:SetFontColor(1,0.97,0.84,1)
			txtOption:SetFontSize(14)
			txtOption.Event.LeftClick = function() MenuItemClicked(control, i) end
			table.insert(control.items, txtOption)
		end

		txtOption:SetVisible(true)

		txtOption.menuItem = v
		if type(v) == "table" then
			txtOption:SetText(v.text or v.value)
		else
			txtOption:SetText(v)
		end
		local w = txtOption:GetWidth()
		if w > maxWidth then maxWidth = w end 
		if not last then
			txtOption:SetPoint("TOPLEFT", control.dropDownBackground, "TOPLEFT", 4, 4)
		else
			txtOption:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, 2)
		end

		last = txtOption
	end

	if last then	
		local top = control:GetTop()
		local bottom = last:GetBottom() + 30
		control:SetHeight(bottom-top)
	else
		control:SetHeight(10)
	end
	control:SetWidth(maxWidth + 50)
	
	for idx,item in ipairs(control.items) do
		item:SetWidth(maxWidth)
		item:EventAttach(Event.UI.Input.Mouse.Cursor.In, function(self, h)
			item:SetBackgroundColor(1,0.97,0.84,0.5)
		end, "Event.UI.Input.Mouse.Cursor.In")
		item:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function(self, h)
			item:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		end, "Event.UI.Input.Mouse.Cursor.Out")
			
	end

end

function WT.Control.Menu.Create(parent, listItems, callback, sort)

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

	local control = UI.CreateFrame("Texture", WT.UniqueName("Menu"), parent)
	control.frameIndex = getmetatable(control).__index
	setmetatable(control, WT.Control.Menu_mt) 
	control:SetLayer(10001)
	control:SetVisible(false)
	control:SetBackgroundColor(1,1,1,0)
	control:SetTexture(AddonId, "img/menu3.png")
	control.callback = callback

	control.dropDownBackground = UI.CreateFrame("Frame", WT.UniqueName("MenuBG"), control)
	control.dropDownBackground:SetBackgroundColor(0,0,0,0)
	control.dropDownBackground:SetPoint("TOPLEFT", control, "TOPLEFT", 20, 20)
	control.dropDownBackground:SetPoint("BOTTOMRIGHT", control, "BOTTOMRIGHT", 50, 50)
	control.dropDownBackground:SetLayer(11000)

	local value = nil

	control.items = {}

	local last = nil
	local maxWidth = 0
	for i,v in ipairs(listItems) do
		local txtOption = UI.CreateFrame("Text", WT.UniqueName("GadgetControlMenuOption"), control.dropDownBackground)
		txtOption:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		txtOption:SetFontColor(1,0.97,0.84,1)
		txtOption:SetFontSize(14)
		txtOption.menuItem = v
		if type(v) == "table" then
			txtOption:SetText(v.text or v.value)
		else
			txtOption:SetText(v)
		end
		
		--txtOption:SetFont(AddonId, "blank-Bold")

		local w = txtOption:GetWidth()
		if w > maxWidth then maxWidth = w end 
		if not last then
			txtOption:SetPoint("TOPLEFT", control.dropDownBackground, "TOPLEFT", 4, 4)
		else
			txtOption:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, 2)
		end
		txtOption:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self, h)
			MenuItemClicked(control,i)
		end, "Event.UI.Input.Mouse.Left.Click")

		last = txtOption
		table.insert(control.items, txtOption)
	end
	
	local top = control:GetTop()
	local bottom = last:GetBottom() + 30 
	control:SetHeight(bottom-top)
	control:SetWidth(maxWidth + 50)
	
	for idx,item in ipairs(control.items) do
		item:SetWidth(maxWidth)
		item:EventAttach(Event.UI.Input.Mouse.Cursor.In, function(self, h)
			item:SetBackgroundColor(1,0.97,0.84,0.5)
		end, "Event.UI.Input.Mouse.Cursor.In")
		item:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function(self, h)
			item:SetBackgroundColor(0.0, 0.0, 0.0, 0.0)
		end, "Event.UI.Input.Mouse.Cursor.Out")
	
	end
	
	
	
	control.GetValue = function() return value end
		
	control.Show = 
		function() 
			if currMenu then currMenu:Hide() end 
			catchAllClicks:SetParent(control:GetParent())
			catchAllClicks:SetVisible(true) 
			currMenu = control 
			WT.FadeIn(control, 0.2) -- fade in
			if control.OnOpen then control:OnOpen() end
		end
		
	control.Hide = 
		function() 
			control:SetVisible(false)
			catchAllClicks:SetVisible(false) 
			if control == currMenu then
				currMenu = false
			end 
			WT.FadeOut(control, 0.2) -- fade out
			if control.OnClose then control:OnClose() end
		end

	control.Toggle = 
		function() 
			if control == currMenu then
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

