-- There is no copyright on this code

-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
-- associated documentation files (the "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is furnished to do so.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
-- LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
-- NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local addon, HowMuch = ...
HowMuch.Tooltip = {}

local MARGIN = 4

local function TooltipMoved(self)
	local yOffset = MARGIN * 2
	self:SetPoint("TOPRIGHT", UI.Native.Tooltip, "BOTTOMRIGHT", 0, yOffset)
	self:SetVisible(self.visible)
end

local function Show(self)
	self:SetLayer(UI.Native.Tooltip:GetLayer())
	local yOffset = MARGIN * 2
	self:SetPoint("TOPRIGHT", UI.Native.Tooltip, "BOTTOMRIGHT", 0, yOffset)
	self.visible = true
end

local function Hide(self)
	self.visible = false
	self:SetVisible(self.visible)
end

local function GetCurrencyValues(ccyValue)
	if ccyValue == nil then
		return 0, 0, 0
	end
	
	local plat = math.floor(ccyValue / 10000)
	local remainder = ccyValue - plat * 10000
	local gold = math.floor(remainder / 100)
	local silver = remainder - gold * 100
	return plat, gold, silver
end

local function GetMaxFieldWidth(widget, field, maxWidth)
	if widget:GetVisible() == true then
		local width = widget[field]:GetWidth()
		return math.max(width, maxWidth)
	else
		return maxWidth
	end
end

local function SetMaxWidth(field, widget, extra)
	local maxWidth = GetMaxFieldWidth(widget.unitAvgFrame, field, 0)
	maxWidth = GetMaxFieldWidth(widget.unitMinFrame, field, maxWidth)
	maxWidth = GetMaxFieldWidth(widget.unitMaxFrame, field, maxWidth)
	maxWidth = GetMaxFieldWidth(widget.totalAvgFrame, field, maxWidth)
	maxWidth = GetMaxFieldWidth(widget.totalMinFrame, field, maxWidth)
	maxWidth = GetMaxFieldWidth(widget.totalMaxFrame, field, maxWidth)
	widget.unitAvgFrame[field]:SetWidth(maxWidth)
	widget.unitMinFrame[field]:SetWidth(maxWidth)
	widget.unitMaxFrame[field]:SetWidth(maxWidth)
	widget.totalAvgFrame[field]:SetWidth(maxWidth)
	widget.totalMinFrame[field]:SetWidth(maxWidth)
	widget.totalMaxFrame[field]:SetWidth(maxWidth)
	return maxWidth + extra
end

local function ClearMoneyFrameWidths(frame)
	frame.labelText:ClearWidth()
	frame.platText:ClearWidth()
	frame.goldText:ClearWidth()
	frame.silverText:ClearWidth()
	frame:ClearWidth()
end

local function SetMoneyFramePosition(widget, frame, lastFrame)
	if frame:GetVisible() == true then
		if lastFrame ~= nil then
			frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0)
		else
			frame:SetPoint("TOPLEFT", widget, "TOPLEFT", MARGIN * 2, MARGIN * 2)
		end
		
		lastFrame = frame
	end
	
	return lastFrame
end

local function SetMoneyFramePositions(widget)
	local margin = MARGIN * 2
	local lastFrame = nil
	lastFrame = SetMoneyFramePosition(widget, widget.unitAvgFrame, lastFrame)
	lastFrame = SetMoneyFramePosition(widget, widget.unitMinFrame, lastFrame)
	lastFrame = SetMoneyFramePosition(widget, widget.unitMaxFrame, lastFrame)
	lastFrame = SetMoneyFramePosition(widget, widget.totalAvgFrame, lastFrame)
	lastFrame = SetMoneyFramePosition(widget, widget.totalMinFrame, lastFrame)
	lastFrame = SetMoneyFramePosition(widget, widget.totalMaxFrame, lastFrame)
end

local function AlignMoneyFrames(widget)
	local width = 0
	width = width + SetMaxWidth("labelText", widget, 0)	
	width = width + SetMaxWidth("platText", widget, widget.textureWidth)
	width = width + SetMaxWidth("goldText", widget, widget.textureWidth)
	width = width + SetMaxWidth("silverText", widget, widget.textureWidth)
	widget.unitAvgFrame:SetWidth(width)
	widget.unitMinFrame:SetWidth(width)
	widget.unitMaxFrame:SetWidth(width)
	widget.totalAvgFrame:SetWidth(width)
	widget.totalMinFrame:SetWidth(width)
	widget.totalMaxFrame:SetWidth(width)
	return width
end

local function SetMoneyFrameValues(widget, value)
	local plat, gold, silver = GetCurrencyValues(value)
	local platVisible = plat > 0
	widget.platText:SetVisible(platVisible)
	widget.platIcon:SetVisible(platVisible)
	
	local goldVisible = (gold > 0) or platVisible
	widget.goldText:SetVisible(goldVisible)
	widget.goldIcon:SetVisible(goldVisible)
	
	widget.platText:SetText(tostring(plat))
	widget.goldText:SetText(tostring(gold))
	widget.silverText:SetText(tostring(silver))
end

local function GetFrameHeight(frame)
	if frame:GetVisible() == true then
		return frame:GetHeight()
	else
		return 0
	end
end

local function GetTotalHeight(self)
	local maxHeight = 0
	maxHeight = maxHeight + GetFrameHeight(self.unitAvgFrame)
	maxHeight = maxHeight + GetFrameHeight(self.unitMinFrame)
	maxHeight = maxHeight + GetFrameHeight(self.unitMaxFrame)
	maxHeight = maxHeight + GetFrameHeight(self.totalAvgFrame)
	maxHeight = maxHeight + GetFrameHeight(self.totalMinFrame)
	maxHeight = maxHeight + GetFrameHeight(self.totalMaxFrame)
	return maxHeight
end

local function SetValues(self, avgValue, minValue, maxValue, quantity)
	ClearMoneyFrameWidths(self.totalAvgFrame)
	ClearMoneyFrameWidths(self.totalMinFrame)
	ClearMoneyFrameWidths(self.totalMaxFrame)
	ClearMoneyFrameWidths(self.unitAvgFrame)
	ClearMoneyFrameWidths(self.unitMinFrame)
	ClearMoneyFrameWidths(self.unitMaxFrame)
	
	self.unitAvgFrame:SetVisible(self.unitAvgVisible)
	self.unitMinFrame:SetVisible(self.unitMinVisible)
	self.unitMaxFrame:SetVisible(self.unitMaxVisible)
	SetMoneyFrameValues(self.unitAvgFrame, avgValue)
	SetMoneyFrameValues(self.unitMinFrame, minValue)
	SetMoneyFrameValues(self.unitMaxFrame, maxValue)
	
	local unitVisible = self.unitAvgFrame:GetVisible() and self.unitMinFrame:GetVisible() and self.unitMaxFrame:GetVisible()
	if quantity == 1 and unitVisible == true then
		self.totalAvgFrame:SetVisible(false)
		self.totalMinFrame:SetVisible(false)
		self.totalMaxFrame:SetVisible(false)
	else
		self.totalAvgFrame:SetVisible(self.totalAvgVisible)
		self.totalMinFrame:SetVisible(self.totalMinVisible)
		self.totalMaxFrame:SetVisible(self.totalMaxVisible)
		SetMoneyFrameValues(self.totalAvgFrame, avgValue * quantity)
		SetMoneyFrameValues(self.totalMinFrame, minValue * quantity)
		SetMoneyFrameValues(self.totalMaxFrame, maxValue * quantity)
		local prefix = ""
		if quantity > 1 then
			prefix = tostring(quantity) .. " x "
		end
		
		self.totalAvgFrame.labelText:SetText(prefix .. "avg = ")
		self.totalMinFrame.labelText:SetText(prefix .. "min = ")
		self.totalMaxFrame.labelText:SetText(prefix .. "max = ")
	end
	
	local width = AlignMoneyFrames(self)
	SetMoneyFramePositions(self)
	self:SetWidth(width + 14)
	self:SetHeight(self:GetTotalHeight() + 16)
end

local function CreateMoneyFrame(name, parent, label)
	local widget = UI.CreateFrame("Frame", name, parent)
	widget:SetBackgroundColor(0, 0, 0, 1)
	widget:SetHeight(20)
	widget:SetWidth(160)

	widget.labelText = UI.CreateFrame("Text", name .. "labelText", widget)
	widget.silverIcon = UI.CreateFrame("Texture", name .. "silverIcon", widget)
	widget.silverText = UI.CreateFrame("Text", name .. "silverText", widget)
	widget.goldIcon = UI.CreateFrame("Texture", name .. "goldIcon", widget)
	widget.goldText = UI.CreateFrame("Text", name .. "goldText", widget)
	widget.platIcon = UI.CreateFrame("Texture", name .. "platIcon", widget)
	widget.platText = UI.CreateFrame("Text", name .. "platText", widget)
	widget.labelText:SetPoint("TOPLEFT", widget, "TOPLEFT")
	widget.platText:SetPoint("BOTTOMLEFT", widget.labelText, "BOTTOMRIGHT", 0, 0)
	widget.platIcon:SetPoint("BOTTOMLEFT", widget.platText, "BOTTOMRIGHT", 0, 0)
	widget.goldText:SetPoint("BOTTOMLEFT", widget.platIcon, "BOTTOMRIGHT", 0, 0)
	widget.goldIcon:SetPoint("BOTTOMLEFT", widget.goldText, "BOTTOMRIGHT", 0, 0)
	widget.silverText:SetPoint("BOTTOMLEFT", widget.goldIcon, "BOTTOMRIGHT", 0, 0)
	widget.silverIcon:SetPoint("BOTTOMLEFT", widget.silverText, "BOTTOMRIGHT", 0, 0)
	
	widget.labelText:SetText(label)
	widget.platIcon:SetTexture(HowMuch.name, "plat.png")
	widget.goldIcon:SetTexture(HowMuch.name, "gold.png")
	widget.silverIcon:SetTexture(HowMuch.name, "silver.png")
	return widget
end

function HowMuch.Tooltip.Create(name, parent)
	local widget = UI.CreateFrame("Frame", name, parent)
	Library.LibSimpleWidgets.SetBorder("tooltip", widget)
	widget.__lsw_border:SetPosition("inside")
	widget.visible = false
	widget.unitAvgVisible = true
	widget.unitMinVisible = true
	widget.unitMaxVisible = true
	widget.totalAvgVisible = true
	widget.totalMinVisible = true
	widget.totalMaxVisible = true
	widget:SetVisible(widget.visible)

	widget.unitAvgFrame = CreateMoneyFrame(name .. "unitAvgFrame", widget, "avg")
	widget.unitMinFrame = CreateMoneyFrame(name .. "unitMinFrame", widget, "min")
	widget.unitMaxFrame = CreateMoneyFrame(name .. "unitMaxFrame", widget, "max")
	widget.totalAvgFrame = CreateMoneyFrame(name .. "totalAvgFrame", widget, "1 x avg")
	widget.totalMinFrame = CreateMoneyFrame(name .. "totalMinFrame", widget, "1 x min")
	widget.totalMaxFrame = CreateMoneyFrame(name .. "totalMaxFrame", widget, "1 x max")
	widget:SetHeight(widget.totalAvgFrame:GetHeight() + widget.totalMinFrame:GetHeight() + widget.totalMaxFrame:GetHeight() + widget.unitAvgFrame:GetHeight() + widget.unitMinFrame:GetHeight() + widget.unitMaxFrame:GetHeight() + 16)
	widget:SetWidth(166)
	widget.textureWidth = widget.totalAvgFrame.platIcon:GetWidth()
	SetMoneyFramePositions(widget)

	widget.MoveCallback = function() TooltipMoved(widget) end
	widget.SizeCallback = function() TooltipMoved(widget) end
	
	widget.Show = Show
	widget.Hide = Hide
	widget.SetValues = SetValues
	widget.GetTotalHeight = GetTotalHeight
	widget.SetUnitAvgVisible = function(self, visible) self.unitAvgVisible = visible end
	widget.SetUnitMinVisible = function(self, visible) self.unitMinVisible = visible end
	widget.SetUnitMaxVisible = function(self, visible) self.unitMaxVisible = visible end
	widget.SetTotalAvgVisible = function(self, visible) self.totalAvgVisible = visible end
	widget.SetTotalMinVisible = function(self, visible) self.totalMinVisible = visible end
	widget.SetTotalMaxVisible = function(self, visible) self.totalMaxVisible = visible end

	UI.Native.Tooltip:EventAttach(Event.UI.Layout.Move, widget.MoveCallback, "HowMuchTooltip.Move")
	UI.Native.Tooltip:EventAttach(Event.UI.Layout.Size, widget.SizeCallback, "HowMuchTooltip.Size")
	
	return widget
end
