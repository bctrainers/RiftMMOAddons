math.randomseed(os.time())

local Info, RM = ...

local VU = Library.VinceUtils

local tinsert = table.insert
local tremove = table.remove
local tconcat = table.concat
local pairs = pairs
local ipairs = ipairs
local floor = math.floor
local type = type
local bit = bit
local max = math.max
local min = math.min
local log10 = math.log10
local pow = math.pow
local tonumber = tonumber
local tostring = tostring
local setmetatable = setmetatable
local getmetatable = getmetatable
local UI = UI
local UIParent = UIParent
local Inspect = Inspect
local CommandEventAttach = Command.Event.Attach
local CommandEventDetach = Command.Event.Detach

local Context = UI.CreateContext("RiftMeter_Utilities")
Context:SetStrata("topmost")
local AsyncFix = ""

local Dialog = {}
RM.Dialog = Dialog
function Dialog:init()
	self.dialog = UI.CreateFrame("Texture", "RM_Dialog", Context)
	self.dialog:SetVisible(false)
	self.dialog:SetWidth(350)
	self.dialog:SetHeight(100)
	self.dialog:SetTexture("Rift", "ItemToolTip_I75.dds")
	self.dialog:SetPoint("CENTER", UIParent, "CENTER", 0, -120)

	self.dialogText = RM.createTextFrame("RM_dialogText", self.dialog)
	self.dialogText:SetFontSize(14)
	self.dialogText:SetPoint("TOPCENTER", self.dialog, "TOPCENTER", 0, 15)

	self.dialogButtonYes = UI.CreateFrame("RiftButton", "RM_dialogButtonYes", self.dialog)
	self.dialogButtonYes:SetText("Yes")
	self.dialogButtonYes:SetPoint("BOTTOMLEFT", self.dialog, "BOTTOMLEFT", 20, -10)

	self.dialogButtonNo = UI.CreateFrame("RiftButton", "RM_dialogButtonNo", self.dialog)
	self.dialogButtonNo:SetText("No")
	self.dialogButtonNo:SetPoint("BOTTOMRIGHT", self.dialog, "BOTTOMRIGHT", -20, -10)
end
function Dialog:show(text, yesLabel, noLabel, yesCallback, noCallback)
	if not self.dialog then
		self:init()
	end
	local dialog = self.dialog

	dialog:SetVisible(true)
	self.dialogText:SetText(text)
	self.dialogButtonYes:SetText(yesLabel)
	self.dialogButtonNo:SetText(noLabel)

	self.dialogButtonYes:EventAttach(Event.UI.Button.Left.Press, function()
		dialog:SetVisible(false)
		yesCallback()
	end, "Event.UI.Button.Left.Press")
	self.dialogButtonNo:EventAttach(Event.UI.Button.Left.Press, function()
		dialog:SetVisible(false)
		noCallback()
	end, "Event.UI.Button.Left.Press")
end


local Tooltip = {
	maxWidth = 210,
	padding = 5,
}
RM.Tooltip = Tooltip
function Tooltip:init()
	self.tooltip = UI.CreateFrame("Frame", "RM_Tooltip", Context)
	self.tooltip:SetVisible(false)
	self.tooltip:SetBackgroundColor(0, 0, 0, 0.70)
	self.tooltip:SetLayer(100)
	--		self.tooltip:SetWidth(self.maxWidth)

	local borderTop = UI.CreateFrame("Frame", "RM_tooltipBorderTop", self.tooltip)
	borderTop:SetBackgroundColor(0.47, 0.47, 0.42)
	borderTop:SetPoint("TOPLEFT", self.tooltip, "TOPLEFT")
	borderTop:SetPoint("BOTTOMRIGHT", self.tooltip, "TOPRIGHT", 0, 1)

	local borderLeft = UI.CreateFrame("Frame", "RM_tooltipBorderLeft", self.tooltip)
	borderLeft:SetBackgroundColor(0.47, 0.47, 0.42)
	borderLeft:SetPoint("TOPLEFT", self.tooltip, "TOPRIGHT", -1, 0)
	borderLeft:SetPoint("BOTTOMRIGHT", self.tooltip, "BOTTOMRIGHT")

	local borderRight = UI.CreateFrame("Frame", "RM_tooltipBorderRight", self.tooltip)
	borderRight:SetBackgroundColor(0.47, 0.47, 0.42)
	borderRight:SetPoint("TOPLEFT", self.tooltip, "TOPLEFT")
	borderRight:SetPoint("BOTTOMRIGHT", self.tooltip, "BOTTOMLEFT", 1, 0)

	local borderBottom = UI.CreateFrame("Frame", "RM_tooltipBorderBottom", self.tooltip)
	borderBottom:SetBackgroundColor(0.47, 0.47, 0.42)
	borderBottom:SetPoint("TOPLEFT", self.tooltip, "BOTTOMLEFT", 0, -1)
	borderBottom:SetPoint("BOTTOMRIGHT", self.tooltip, "BOTTOMRIGHT")

	self.tooltipText = RM.createTextFrame("RM_tooltipText", self.tooltip)
	self.tooltipText:SetWordwrap(false)
	self.tooltipText:SetFontSize(13)
	self.tooltipText:SetText("", true)
end
function Tooltip:show(text, anchor, center)
	if not text then
		return
	end

	if not self.tooltip then
		self:init()
	end

	self.tooltip:ClearAll()
	self.tooltipText:ClearAll()

	if center then
		self.tooltipText:SetPoint("TOPCENTER", self.tooltip, "TOPCENTER", 0, self.padding)
	else
		self.tooltipText:SetPoint("TOPLEFT", self.tooltip, "TOPLEFT", self.padding, self.padding)
	end
	self.tooltipText:SetText(text, true)

	--		local width = min(self.tooltipText:GetWidth() + 1, self.maxWidth - 2 * self.padding)
	--		self.tooltipText:SetWidth(width)

	self.tooltipText:SetWidth(self.tooltipText:GetWidth() + 1) -- dafuq?
	self.tooltip:SetWidth(self.tooltipText:GetWidth() + 2 * self.padding)
	self.tooltip:SetHeight(self.tooltipText:GetHeight() + 2 * self.padding)

	if anchor then
		self.tooltip:SetPoint("BOTTOMCENTER", anchor, "TOPCENTER", 0, -10)
	else
		self.tooltip:SetPoint("BOTTOMRIGHT", UI.Native.TooltipAnchor, "BOTTOMRIGHT")
	end

	self.tooltip:SetVisible(true)
end
function Tooltip:hide()
	if not self.tooltip then
		return
	end
	self.tooltip:SetVisible(false)
end
function Tooltip.createForFrame(frame, text, anchor, center, shouldShowFunc)
	frame:EventAttach(Event.UI.Input.Mouse.Cursor.In, function()
		if not shouldShowFunc or shouldShowFunc() then
			AsyncFix = frame
			Tooltip:show(text, anchor, center)
		end
	end, "Tooltip MouseIn")
	frame:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function()
		if frame == AsyncFix then
			Tooltip:hide()
		end
	end, "Tooltip MouseOut")
end



local TextEffect = {}
function RM.createTextFrame(name, context)
	local frame = UI.CreateFrame("Text", name, context)
	frame:SetEffectGlow(TextEffect)
	return frame
end

function RM.triggerFrameEvent(frame, event)
	for _, e in ipairs(frame:EventList(event)) do
		if e.handler then
			e.handler(frame)
		end
	end
end

--function RM.insertOrUpdateFrameEvent(frame, event, label, newEvent)
--	for _, e in ipairs(frame:EventList(event)) do
--		if e.label == label then
--			e.handle = handle
--			return
--		end
--	end
--	frame:EventAttach(event, unpack(newEvent))
--end

function RM.decToHex(tbl)
	return ("%02X%02X%02X"):format(VU.round(tbl[1] * 255), VU.round(tbl[2] * 255), VU.round(tbl[3] * 255))
end

function RM.registerEventIfNotExists(event, callback, label, priority)
	for i, event2 in ipairs(Inspect.Event.List(event)) do
		if event2.handler == callback then
			return
		end
	end
	CommandEventAttach(event, callback, label, priority or 0)
end

function RM.formatSeconds(seconds)
	local minutes = floor(seconds / 60)
	seconds = floor(seconds % 60)
	return ("%02d:%02d"):format(minutes, seconds)
end

local units = {"k", "M", "G", "T", "P", "E", "Z", "Y"};
function RM.numberFormat(num)
	if RiftMeter_abbreviateNumbers then
		local unit = min(floor(log10(max(num, 1)) / 3), #units)
		return ("%.4g%s"):format(unit == 0 and num or num / pow(10, unit * 3), unit == 0 and "" or " " .. units[unit])
	else
		local str = tostring(VU.round(num))
		local formatted = str:reverse():gsub("(%d%d%d)","%1,"):reverse()
		return str:len() % 3 == 0 and formatted:sub(2) or formatted
	end
end

--[[
	Adds basic functionality to RiftWindow
	Created and returned frames:
		RiftWindow 		window
		Frame 			window.titleBar
		RiftButton		window.titleBar.close

	Example for closeCallback:
	function(frame)
		frame:SetVisible(false)
	end
--]]
function RM.createWindow(name, context, closeCallback)
	local window = UI.CreateFrame("RiftWindow", name, context)
	window:SetController("content")

	local border = window:GetBorder()
	local content = window:GetContent()

	local titleBar = UI.CreateFrame("Frame", name .. "_titleBar", window)
	window.titleBar = titleBar
	titleBar:SetPoint("TOPLEFT", border, "TOPLEFT")
	titleBar:SetPoint("RIGHT", border, "RIGHT")
	titleBar:SetWidth(window:GetWidth())
	titleBar:SetHeight(({window:GetTrimDimensions()})[2])

	local close = UI.CreateFrame("RiftButton", name .. "_titleBar_close", titleBar)
	window.titleBar.close = close
	close:SetSkin("close")
	close:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", -8, 16)
	close:EventAttach(Event.UI.Button.Left.Press, function()
		closeCallback(window)
	end, "Event.UI.Button.Left.Press")

	titleBar:EventAttach(Event.UI.Input.Mouse.Left.Down, function()
		local mouse = Inspect.Mouse()
		titleBar.pressed = true
		titleBar.mouseStartX = mouse.x
		titleBar.mouseStartY = mouse.y
		titleBar.startX = window:GetLeft()
		titleBar.startY = window:GetTop()
	end, "Event.UI.Input.Mouse.Left.Down")
	titleBar:EventAttach(Event.UI.Input.Mouse.Cursor.Move, function()
		if titleBar.pressed then
			local mouse = Inspect.Mouse()
			window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", mouse.x - titleBar.mouseStartX + titleBar.startX, mouse.y - titleBar.mouseStartY + titleBar.startY)
		end
	end, "Event.UI.Input.Mouse.Cursor.Move")
	titleBar:EventAttach(Event.UI.Input.Mouse.Left.Upoutside, function()
		titleBar.pressed = false
	end, "Event.UI.Input.Mouse.Left.Upoutside")
	titleBar:EventAttach(Event.UI.Input.Mouse.Left.Up, function()
		titleBar.pressed = false
	end, "Event.UI.Input.Mouse.Left.Up")

	return window
end

function RM.createSlider(name, context, text, minRange, maxRange, position, callback)
	local slider = UI.CreateFrame("RiftSlider", name, context)
	slider:SetRange(minRange, maxRange)
	slider:SetPosition(position)
	slider:SetWidth(slider:GetWidth() / 1.5)

	local label = RM.createTextFrame(name .. "_Label", slider)
	label:SetPoint("CENTER", slider, "CENTER", 0, -slider:GetHeight())
	label:SetFontColor(1, .82, 0)
	label:SetText(text)

	local sliderLeftLabel = RM.createTextFrame(name .. "_LeftLabel", slider)
	sliderLeftLabel:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -14)
	sliderLeftLabel:SetText(tostring(minRange))

	local sliderRightLabel = RM.createTextFrame(name .. "_RightLabel", slider)
	sliderRightLabel:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, -14)
	sliderRightLabel:SetText(tostring(maxRange))

	-- typed the new value in textarea?
--	local typed = false

--	local textfield = UI.CreateFrame("RiftTextfield", name .. "_Textfield", slider)
--	textfield:SetPoint("CENTER", slider, "CENTER", 0, slider:GetHeight() - 8)
--	textfield:SetWidth(slider:GetWidth() / 4)
--	textfield:SetBackgroundColor(0, 0, 0, .5)
--	textfield:SetText(tostring(position))
--	textfield:EventAttach(Event.UI.Textfield.Change, function()
--		local pos = tonumber(textfield:GetText()) or minRange
--		typed = true
--		slider:SetPosition(pos)
--	end, "Event.UI.Textfield.Change")

	local value = RM.createTextFrame(name .. "_Value", slider)
	value:SetPoint("CENTER", slider, "CENTER", 0, slider:GetHeight() - 14)

	slider:EventAttach(Event.UI.Slider.Change, function()
		local pos = slider:GetPosition()
		value:SetText(tostring(pos))
--		if not typed then
--			textfield:SetText(tostring(pos))
--		end
--		typed = false
		callback(pos)
	end, "Event.UI.Slider.Change")

	return slider, label, sliderLeftLabel, sliderRightLabel
end

function RM.createCheckboxWithLabel(name, context, anchor, parent, parentAnchor, x, y, state, label, callback)
	local checkbox = UI.CreateFrame("RiftCheckbox", name, context)
	checkbox:SetPoint(anchor, parent, parentAnchor, x, y)
	checkbox:SetChecked(state)
	checkbox:EventAttach(Event.UI.Checkbox.Change, function()
		callback(checkbox:GetChecked())
	end, "Event.UI.Checkbox.Change")

	local text = RM.createTextFrame(name .. "Label", context)
	text:SetPoint("CENTERLEFT", checkbox, "CENTERRIGHT")
	text:SetFontSize(13)
	text:SetText(label)
	text:EventAttach(Event.UI.Input.Mouse.Left.Click, function()
		checkbox:SetChecked(not checkbox:GetChecked())
	end, "Event.UI.Input.Mouse.Left.Click")

	text:EventAttach(Event.UI.Input.Mouse.Cursor.In, function()
		text:SetFontColor(0.85, 0.85, 0.85)
--		text:SetFontColor(math.random(), math.random(), math.random())
	end, "Event.UI.Input.Mouse.Cursor.In")
	text:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function()
		text:SetFontColor(1, 1, 1)
	end, "Event.UI.Input.Mouse.Cursor.Out")
	checkbox:EventAttach(Event.UI.Input.Mouse.Cursor.In, function()
		text:SetFontColor(0.85, 0.85, 0.85)
--		text:SetFontColor(math.random(), math.random(), math.random())
	end, "Event.UI.Input.Mouse.Cursor.In")
	checkbox:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function()
		text:SetFontColor(1, 1, 1)
	end, "Event.UI.Input.Mouse.Cursor.Out")

	return checkbox, text
end

function RM.createIconButton(name, context, icon, anchor, parent, parentAnchor, x, y, tooltipText, shouldShowFunc, click)
	local button = UI.CreateFrame("Texture", name, context)
	button:SetTexture("RiftMeter", icon)
	button:SetPoint(anchor, parent, parentAnchor, x, y)
	button:SetLayer(1)
	button:EventAttach(Event.UI.Input.Mouse.Left.Click, click, "Event.UI.Input.Mouse.Left.Click")

	Tooltip.createForFrame(button, tooltipText, button, true, shouldShowFunc)

	return button
end

function RM.createColorPickerPreviewButton(name, context, r, g, b, a, callback)
	local bg = UI.CreateFrame("Frame", name, context)
	bg:SetBackgroundColor(r, g, b, a or 1)
	bg:SetWidth(24)
	bg:SetHeight(24)

	local overlay = UI.CreateFrame("Texture", name .. "_Overlay", bg)

	local function change(r, g, b, a)
		bg:SetBackgroundColor(r, g, b, a)
		callback(r, g, b, a)
	end

	local function hideCallback()
		overlay:SetTexture("Rift", [[sml_icon_border.png.dds]])
	end

	overlay:SetPoint("TOPLEFT", bg, "TOPLEFT", -4, -4)
	overlay:SetTexture("Rift", [[sml_icon_border.png.dds]])
	overlay:EventAttach(Event.UI.Input.Mouse.Cursor.In, function()
		overlay:SetTexture("Rift", [[sml_icon_border_(over)_blue.png.dds]])
	end, "Event.UI.Input.Mouse.Cursor.In")
	overlay:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function()
		if not Library.ColorPicker:getVisible() or Library.ColorPicker.hideCallback ~= hideCallback then
			overlay:SetTexture("Rift", [[sml_icon_border.png.dds]])
		end
	end, "Event.UI.Input.Mouse.Cursor.Out")
	overlay:EventAttach(Event.UI.Input.Mouse.Left.Down, function()
		overlay:SetTexture("Rift", [[sml_icon_border_(click)_blue.png.dds]])
	end, "Event.UI.Input.Mouse.Left.Down")
	overlay:EventAttach(Event.UI.Input.Mouse.Left.Up, function()
		overlay:SetTexture("Rift", [[sml_icon_border_(over)_blue.png.dds]])

		if Library.ColorPicker:getVisible() then
			Library.ColorPicker:hide()

			if Library.ColorPicker.hideCallback ~= hideCallback then
				local colors = {bg:GetBackgroundColor()}
				Utility.Dispatch(function() Library.ColorPicker:show(colors[1], colors[2], colors[3], colors[4], change) end, "ColorPicker", "Color Picker")
				Library.ColorPicker.hideCallback = hideCallback
			end
		else
			local colors = {bg:GetBackgroundColor()}
			Utility.Dispatch(function() Library.ColorPicker:show(colors[1], colors[2], colors[3], colors[4], change) end, "ColorPicker", "Color Picker")
			Library.ColorPicker.hideCallback = hideCallback
		end
	end, "Event.UI.Input.Mouse.Left.Up")

	return bg
end

function RM.colorize(text, fromHex, toHex)
	local colored = {}
	local len = text:len() - 1


	local from = {RM.extractColors(fromHex)}
	local to = {RM.extractColors(toHex)}

	local step = {
		r = (to[1] - from[1]) / len,
		g = (to[2] - from[2]) / len,
		b = (to[3] - from[3]) / len
	}

	for char in text:gmatch(".") do
		if char == " " then
			tinsert(colored, " ")
		else
			tinsert(colored, ("<font color=\"#%02x%02x%02x\">%s</font>"):format(from[1], from[2], from[3], char))
		end
		from[1] = from[1] + step.r
		from[2] = from[2] + step.g
		from[3] = from[3] + step.b
	end

	return tconcat(colored)
end

-- number to r, g, b
function RM.extractColors(num)
	return bit.rshift(num, 16), bit.band(bit.rshift(num, 8), 0xff), bit.band(num, 0xff)
end

-- r, g, b to number
function RM.toColor(tbl)
	return bit.bor(bit.lshift(tbl[1], 16), bit.lshift(tbl[2], 8), tbl[3])
end


local TabControl = {}
RM.TabControl = TabControl
function TabControl:new(name, context)
	local self = UI.CreateFrame("Frame", name, context)
	local selfMtIndexFunction = getmetatable(self).__index

	self.tabsFrame = UI.CreateFrame("Frame", name .. "_TabsFrame", self)
	self.tabsFrame:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.tabsFrame:SetPoint("RIGHT", self, "RIGHT")
	self.tabsFrame:SetHeight(30)

	self.tabsFrameBorder = UI.CreateFrame("Frame", self.tabsFrame:GetName() .. "_Border", self.tabsFrame)
	self.tabsFrameBorder:SetBackgroundColor(0, 0, 0, .4)
	self.tabsFrameBorder:SetPoint("TOPLEFT", self.tabsFrame, "BOTTOMLEFT")
	self.tabsFrameBorder:SetPoint("BOTTOMRIGHT", self.tabsFrame, "BOTTOMRIGHT", 0, 2)

	self.tabContent = UI.CreateFrame("Frame", name .. "_TabContent", self)
	self.tabContent:SetPoint("TOPLEFT", self.tabsFrame, "BOTTOMLEFT")
	self.tabContent:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")

	self.tabs = {}
	self.selectedTab = 0

	return setmetatable(self, {__index = function(t, k)
		return selfMtIndexFunction[k] or TabControl[k]
	end})
end
function TabControl:newTab(label)
	local tab = {}
	tinsert(self.tabs, tab)
	local index = #self.tabs

	tab.contentFrame = UI.CreateFrame("Frame", self:GetName() .. "_Tab_" .. index .. "_Content", self.tabContent)
	tab.tabFrame = UI.CreateFrame("Frame", self:GetName() .. "_Tab_" .. index, self.tabsFrame)
	tab.tabTexture = UI.CreateFrame("Texture", self:GetName() .. "_Tab_" .. index .. "_Texture", tab.tabFrame)
	tab.tabLabel = RM.createTextFrame(self:GetName() .. "_Tab_" .. index .. "_Label", tab.tabFrame)

	tab.tabLabel:SetPoint("CENTER", tab.tabTexture, "CENTER", 0, 2)
	tab.tabLabel:SetLayer(2)
	tab.tabLabel:SetFontSize(14)
	tab.tabLabel:SetFontColor(.64, .63, .55)
	tab.tabLabel:SetText(tostring(label))

	tab.tabTexture:SetTexture(Info.identifier, [[textures\tab_off.png]])
	tab.tabTexture:SetAllPoints(tab.tabFrame)
	tab.tabTexture:SetLayer(1)

	tab.tabTexture:EventAttach(Event.UI.Input.Mouse.Cursor.In, function()
		if self:getSelectedTab() ~= index then
			tab.tabLabel:SetFontSize(15)
		end
		tab.tabLabel:SetFontColor(1, 1, 1)
	end, "Event.UI.Input.Mouse.Cursor.In")
	tab.tabTexture:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function()
		if self:getSelectedTab() ~= index then
			tab.tabLabel:SetFontSize(14)
			tab.tabLabel:SetFontColor(.64, .63, .55)
		else
			tab.tabLabel:SetFontColor(1, 1, 1)
		end
	end, "Event.UI.Input.Mouse.Cursor.Out")
	tab.tabTexture:EventAttach(Event.UI.Input.Mouse.Left.Down, function()
		tab.tabLabel:SetFontSize(14)
		tab.tabLabel:SetFontColor(.74, .74, .74)
	end, "Event.UI.Input.Mouse.Left.Down")
	tab.tabTexture:EventAttach(Event.UI.Input.Mouse.Left.Up, function()
		self:setSelectedTab(index)
		tab.tabLabel:SetFontColor(1, 1, 1)
		tab.tabLabel:SetFontSize(15)
	end, "Event.UI.Input.Mouse.Left.Up")
	tab.tabTexture:EventAttach(Event.UI.Input.Mouse.Left.Upoutside, function()
		if self:getSelectedTab() == index then
			tab.tabLabel:SetFontSize(15)
		end
	end, "Event.UI.Input.Mouse.Left.Upoutside")

	tab.tabFrame:SetWidth(tab.tabLabel:GetWidth() + 40)
	tab.tabFrame:SetPoint("BOTTOM", self.tabsFrame, "BOTTOM")
	if index > 1 then
		tab.tabFrame:SetPoint("TOPLEFT", self.tabs[index - 1].tabFrame, "TOPRIGHT", 2, 0)
	else
		tab.tabFrame:SetPoint("TOPLEFT", self.tabsFrame, "TOPLEFT")
	end

	tab.contentFrame:SetVisible(false)
	tab.contentFrame:SetAllPoints(self.tabContent)

	if index == 1 then
		self:setSelectedTab(1)
	end

	return tab
end
function TabControl:setSelectedTab(index)
	if index == self.selectedTab then
		return
	end

	self.selectedTab = max(min(tonumber(index) or 0, #self.tabs), 0)

	if self.selectedTab < 1 then
		return
	end

	for i, tab in ipairs(self.tabs) do
		tab.tabLabel:SetFontSize(14)
		tab.tabLabel:SetFontColor(.64, .63, .55)
		tab.tabTexture:SetTexture(Info.identifier, [[textures\tab_off.png]])
		tab.contentFrame:SetVisible(false)
	end

	local tab = self.tabs[self.selectedTab]
	tab.tabLabel:SetFontSize(15)
	tab.tabLabel:SetFontColor(1, 1, 1)
	tab.tabTexture:SetTexture(Info.identifier, [[textures\tab_on.png]])
	tab.contentFrame:SetVisible(true)
end
function TabControl:getSelectedTab()
	return self.selectedTab
end



local ListBox = {}
RM.ListBox = ListBox
function ListBox:new(name, context, grow)
	local self = UI.CreateFrame("Frame", name, context)
	local selfMtIndexFunction = getmetatable(self).__index

	local borderTop = UI.CreateFrame("Frame", self:GetName() .. "_BorderTop", self)
	local borderBottom = UI.CreateFrame("Frame", self:GetName() .. "_BorderBottom", self)
	local borderLeft = UI.CreateFrame("Frame", self:GetName() .. "_BorderLeft", self)
	local borderRight = UI.CreateFrame("Frame", self:GetName() .. "_BorderRight", self)

	borderTop:SetPoint("TOPLEFT", self, "TOPLEFT", -1, -1)
	borderTop:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 1, 0)
	borderBottom:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -1, 1)
	borderBottom:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 1, 0)
	borderLeft:SetPoint("TOPLEFT", self, "TOPLEFT", -1, 0)
	borderLeft:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT")
	borderRight:SetPoint("TOPRIGHT", self, "TOPRIGHT", 1, 0)
	borderRight:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT")

	borderTop:SetBackgroundColor(0, 0, 0, .5)
	borderBottom:SetBackgroundColor(0, 0, 0, .5)
	borderLeft:SetBackgroundColor(0, 0, 0, .5)
	borderRight:SetBackgroundColor(0, 0, 0, .5)

	self.items = {}
	self.totalAddCount = 0
	self.selectedIndex = 0
	self.grow = not not grow

	return setmetatable(self, {__index = function(t, k)
		return selfMtIndexFunction[k] or ListBox[k]
	end})
end
function ListBox:addItem(label)
	local item = {}
	tinsert(self.items, item)
	self.totalAddCount = self.totalAddCount + 1

	item.index = #self.items

	item.frame = UI.CreateFrame("Frame", self:GetName() .. "_Item_" .. self.totalAddCount, self)
	item.label = RM.createTextFrame(self:GetName() .. "_Item_" .. self.totalAddCount .. "_Label", item.frame)

	item.label:SetPoint("CENTERLEFT", item.frame, "CENTERLEFT")
	item.label:SetPoint("RIGHT", item.frame, "RIGHT")
	item.label:SetText(tostring(label))

	item.frame:EventAttach(Event.UI.Input.Mouse.Cursor.In, function()
		item.frame:SetBackgroundColor(0, 0, 0, .3)
	end, "Event.UI.Input.Mouse.Cursor.In")
	item.frame:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function()
		if self:getSelectedIndex() ~= item.index then
			item.frame:SetBackgroundColor(0, 0, 0, 0)
		else
			item.frame:SetBackgroundColor(0, 0, 0, .4)
		end
	end, "Event.UI.Input.Mouse.Cursor.Out")
	item.frame:EventAttach(Event.UI.Input.Mouse.Left.Click, function()
		self:setSelectedIndex(item.index)
	end, "Event.UI.Input.Mouse.Left.Click")

	item.frame:SetHeight(20)
	item.frame:SetPoint("RIGHT", self, "RIGHT")
	if item.index > 1 then
		item.frame:SetPoint("TOPLEFT", self.items[item.index - 1].frame, "BOTTOMLEFT")
	else
		item.frame:SetPoint("TOPLEFT", self, "TOPLEFT")
	end

	if self.grow then
		self:SetPoint("BOTTOM", item.frame, "BOTTOM")
	end

	if item.index == 1 then
		self:setSelectedIndex(1)
	end
end
function ListBox:removeItem(index)
	index = tonumber(index) or 0

	if index < 1 and index > #self.items then
		return
	end

	self.items[index].frame:SetVisible(false)

	if index == 1 and #self.items > 1 then
		self.items[2].frame:SetPoint("TOPLEFT", self, "TOPLEFT")
	elseif index > 1 and index < #self.items then
		self.items[index + 1].frame:SetPoint("TOPLEFT", self.items[index - 1].frame, "BOTTOMLEFT")
	end

	tremove(self.items, index)

	for i, item in ipairs(self.items) do
		item.index = i
	end

	if self.grow and #self.items > 0 then
		self:SetPoint("BOTTOM", self.items[#self.items].frame, "BOTTOM")
	end

	self:setSelectedIndex(min(self:getSelectedIndex(), #self.items))
end
function ListBox:setLabel(index, label)
	self.items[index].label:SetText(tostring(label))
end
function ListBox:setFontColor(index, r, g, b)
	self.items[index].label:SetFontColor(r, g, b)
end
function ListBox:setSelectedIndex(index)
	self.beforeSelectionChange()

	self.selectedIndex = max(min(tonumber(index) or 0, #self.items), 0)

	if self.selectedIndex < 1 then
		return
	end

	for i, item in ipairs(self.items) do
		item.frame:SetBackgroundColor(0, 0, 0, 0)
	end

	self.items[self.selectedIndex].frame:SetBackgroundColor(0, 0, 0, .4)

	self.selectionChange()
end
function ListBox:getSelectedIndex()
	return self.selectedIndex
end
function ListBox:getItemCount()
	return #self.items
end
function ListBox.selectionChange()
end
function ListBox.beforeSelectionChange()
end









local FontDialog = {}
RM.FontDialog = FontDialog
function FontDialog.Init()
	if FontDialog.window then
		return
	end

end
function FontDialog.Show()
	if not FontDialog.window then
		FontDialog.Init()
	end

	FontDialog.window:SetVisible(true)
end
function FontDialog.Hide()
	if FontDialog.window then
		FontDialog.window:SetVisible(false)
	end
end
function FontDialog.Toggle()
	if not FontDialog.window or not FontDialog.window:GetVisible() then
		FontDialog.Show()
	else
		FontDialog.Hide()
	end
end
