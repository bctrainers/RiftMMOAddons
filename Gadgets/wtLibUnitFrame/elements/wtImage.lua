--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	Image
	
		Provides an image element, used for displaying a single static image (texture)	
--]]

-- Create the class.
local wtImage = WT.Element:Subclass("Image", "Texture")

function wtImage:Construct()
	-- self is a Texture

	local config = self.Configuration
	local unitFrame = self.UnitFrame

	-- Validate the configuration
	
	if config.media then
		Library.Media.SetTexture(self, config.media)
	else
		if not config.texAddon then error("Image missing required configuration item: texAddon") end
		if not config.texFile then error("Image missing required configuration item: texFile") end
		self:SetTexture(config.texAddon, config.texFile)
	end
	
	if config.width then self:SetWidth(config.width) end
	if config.height then self:SetHeight(config.height) end

	if config.color then 
		self:SetBackgroundColor(config.color.r or 0, config.color.g or 0, config.color.b or 0, config.color.a or 1) 
	end

end