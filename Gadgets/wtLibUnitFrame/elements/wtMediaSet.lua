--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	WT.Element.MediaSet
	
		Provides a MediaSet element, which is used to store a set of identically shaped images (tiles), and
		select an image by specifying an index or a name (names can be used for bindings)	
--]]

-- Create the class.
local wtMediaSet = WT.Element:Subclass("MediaSet", "Texture")

-- The Construct method builds the element up. The element (self) is an instance of the relevant
-- UI.Frame as specified in the Subclass() call above
function wtMediaSet:Construct()

	local config = self.Configuration
	local unitFrame = self.UnitFrame

	-- Create a copy of any names provided in the config
	self.names = {}
	if config.names then
		for k,v in pairs(config.names) do self.names[k] = v end
	end
	
	-- do we have an override to set the width/height of the image
	--[[
	if config.width then
		self:SetWidth(config.width)
	end
	--]]
	self:SetWidth(0)
	
	if config.height then
		self:SetHeight(config.height)
	end
	
	if config.nameBinding then
		unitFrame:CreateBinding(config.nameBinding, self, self.SetName, config.defaultName or "")
	end

end

--[[
function wtMediaSet:Refresh()
	if self:GetWidth() < 0.5 or self.currIndex == "hide" then return end
	self:SetWidth(self.tileWidth)
	local idx = self.currIndex % self.wrapIndex 
	local col = (idx % self.cols)
	local row = math.floor(idx / self.cols)
	self.image:SetPoint("TOPLEFT", self, "TOPLEFT", -col * self.tileWidth, -row * self.tileHeight)
end
--]]

function wtMediaSet:SetName(name)
	if (not name) or (name == "") or (not self.names[name]) then 
		self:SetWidth(0)
		self:SetVisible(false) 
		return
	end	
	local media = Library.Media.GetTexture(self.names[name])
	if media then
		self:SetVisible(true) 
		if self.Configuration.width then
			self:SetWidth(self.Configuration.width)
		else
			self:ClearWidth()
		end
		self:SetTexture(media.addonId, media.filename)
	else
		self:SetWidth(0)
		self:SetVisible(false) 
	end
end
