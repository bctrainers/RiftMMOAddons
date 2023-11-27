--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	WT.Label
	
		Provides a StaticLabel element, which is used to display static text within a UnitFrame.
		
		The text configuration item is applied to the label, and no bindings are set up. However, the text
		can be changed using SetText() as normal.
--]]

-- Create the class.
-- This will be automatically registered as an Element factory with the name "StaticLabel"
-- The base frame type is "Text"
local wtStaticLabel = WT.Element:Subclass("StaticLabel", "Text")

-- The Construct method builds the element up. The element (self) is an instance of the relevant
-- UI.Frame as specified in the Subclass() call above ("Text")
function wtStaticLabel:Construct()

	local config = self.Configuration
	local unitFrame = self.UnitFrame

	-- Validate configuration
	if not config.text then error("StaticLabel missing required configuration item: text") end
	
	self:SetText(config.text)
	
	if config.fontSize then
		self:SetFontSize(config.fontSize)
	end
	
	if config.color then
		self:SetFontColor(config.color.r or 0, config.color.g or 0, config.color.b or 0, config.color.a or 1) 
	end
	
end
