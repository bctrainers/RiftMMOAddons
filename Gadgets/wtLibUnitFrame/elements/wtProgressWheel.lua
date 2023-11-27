--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	WT.ProgressWheel
	
		Provides a simple progress wheel, showing a pie chart with 5% increments
		
--]]

-- Create the class.
-- This will be automatically registered as an Element factory with the name "Label"
-- The base frame type is "Text"
local wtProgressWheel = WT.Element:Subclass("ProgressWheel", "Text")

-- The Construct method builds the element up. The element (self) is an instance of the relevant
-- UI.Frame as specified in the Subclass() call above ("Text")
function wtProgressWheel:Construct()

	local config = self.Configuration
	local unitFrame = self.UnitFrame

	self.gauge = UI.CreateFrame("Text", "Gauge", self)

	self:SetFont("wtLibUnitFrame", "wtProgress.ttf")
	self.gauge:SetFont("wtLibUnitFrame", "wtProgress.ttf")
	self:SetText("u")
	self:SetFontSize(16)

	self.gauge:SetAllPoints(self)
	self.gauge:SetFontSize(16) 

	if config.size then
		self:SetFontSize(config.size)
		self.gauge:SetFontSize(config.size)
	end

	if config.backgroundColor then
		self:SetFontColor(config.backgroundColor.r or 0, config.backgroundColor.g or 0, config.backgroundColor.b or 0, config.backgroundColor.a or 1)
	else 
		self:SetFontColor(0,0,0,1)
	end

	if config.color then
		self.gauge:SetFontColor(config.color.r or 0, config.color.g or 0, config.color.b or 0, config.color.a or 1)
	else 
		self.gauge:SetFontColor(1,1,1,1)
	end
	
	if config.colorBinding then
		unitFrame:CreateBinding(config.colorBinding, self, self.BindColor, nil)
	end
	
	if config.outline then
		self:SetEffectGlow({ strength = 2 })
	end
	
	unitFrame:CreateBinding(config.binding, self, self.BindPercent, 0)
	
end

function wtProgressWheel:BindPercent(percentage)
	local p = percentage
	if p < 0 then p = 0 end
	if p > 100 then p = 100 end
	local c = string.char(string.byte('a') + math.floor(p/5))
	if c ~= self.gauge:GetText() then
		self.gauge:SetText(c)
	end
end


function wtProgressWheel:BindColor(color)
	if color then
		self.gauge:SetFontColor(color.r or 0, color.g or 0, color.b or 0, color.a or 1)
	else
		self.gauge:SetFontColor(1, 1, 1, 1)
	end
end
