--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	WT.Bar
	
		Provides a horizontal bar element, which is used to display a bar bound to a percentage field
		
		*Change: The bar's mask is now contained within a Frame which is set to the element width/height. 
		This allows other elements to be attached to the bar without moving around as the bar shrinks/grows.
		Previously the bar was represented by the Mask frame itself.

--]]

-- Create the class.
-- This will be automatically registered as an Element factory with the name "Label"
-- The base frame type is "Text"
local wtHealthCap = WT.Element:Subclass("HealthCap", "Frame")

wtHealthCap.ConfigDefinition = 
{
	description = "A bar element. This must be bound to a percentage property (returns a number between 0 and 100).",
	required = 
	{
		binding = "The property to bind to. Must be a percentage property (0..100)",
	},
	optional = 
	{
		texAddon = "The addon ID for the addon containing the bar texture",
		texFile = "The filename of the texture for the bar",
		media = "MediaID for the texture, for use with LibMedia",
		width = "The width of the bar",
		height = "The height of the bar",
		colorBinding = "A binding to allow a colour to be auto assigned to the bar (e.g. roleColor, callingColor)",
		color = "A table containing {r,g,b,a} members (0..1)",
		growthDirection = "the direction the bar grows in, up, down, left or right (default is right)",
	},
}


-- The Construct method builds the element up. The element (self) is an instance of the relevant
-- UI.Frame as specified in the Subclass() call above
function wtHealthCap:Construct()

	local config = self.Configuration
	local unitFrame = self.UnitFrame
	
	self.Mask = UI.CreateFrame("Mask", "BarMask", self)
	
	if (config.width) then self:SetWidth(config.width) end
	if (config.height) then self:SetHeight(config.height) end

	self:SetGrowthDirection(config.growthDirection or "right")

	self.Image = UI.CreateFrame("Texture", WT.UnitFrame.UniqueName(), self.Mask)
	
	if config.media then
		Library.Media.SetTexture(self.Image, config.media)
	elseif config.texAddon and config.texFile then
		self.Image:SetTexture(config.texAddon, config.texFile)
	end
	
	self.Image:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.Image:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	
	local a = self.Mask:GetWidth() 	
	local b = self.Mask:GetHeight() 
	
	unitFrame:CreateBinding(config.binding, self, self.BindPercent, 0)
		
	if config.colorBinding then
		self.UnitFrame:CreateBinding(config.colorBinding, self, self.BindColor, nil)
	end

	if config.color then
		self:SetBarColor(config.color.r, config.color.g, config.color.b, config.color.a)
	end

	if config.backgroundColor then
		self:SetBackgroundColor(config.backgroundColor.r or 0, config.backgroundColor.g or 0, config.backgroundColor.b or 0, config.backgroundColor.a or 1)
	end
	
------------------------Add debuffmarker-----------------------------------------------------
	local unitFrame2 = self.Mask
        local nameBase = unitFrame2:GetName()
		local parent = unitFrame2:GetParent()
		local unitFrameLayer = unitFrame2:GetLayer()
	    self.width = width or 0
	    self.position = "inside"
		local width = self.width 	  	
  
  if not config.rightBorder == true then
	  self.left = UI.CreateFrame("Texture", nameBase .."_LeftBorder", parent)
      self.left:SetLayer(100)
      self.left:ClearAll()
      self.left:SetPoint("TOPRIGHT", unitFrame2, "TOPLEFT", 0, -a)
      self.left:SetPoint("BOTTOMRIGHT", unitFrame2, "BOTTOMLEFT", 8, a)
	  self.left:SetTexture("Rift","raid_healthbar_debuffmarker.png.dds")
	  self.left:SetVisible(true)
	  self.left:SetParent(self.Mask)
	 else
	  self.right = UI.CreateFrame("Texture", nameBase .."_RightBorder", parent)
      self.right:SetLayer(100)
      self.right:ClearAll()
	  self.right:SetPoint("TOPLEFT", unitFrame2, "TOPRIGHT", 0, -a)
      self.right:SetPoint("BOTTOMLEFT", unitFrame2, "BOTTOMRIGHT", -8, a)
	  self.right:SetTexture("Rift","raid_healthbar_debuffmarker.png.dds")
	  self.right:SetVisible(true)
	  self.right:SetParent(self.Mask)
	end	 
  -------------------------------------------------------------------------------------------------------
end

function wtHealthCap:BindPercent(percentage)
	if (self.growthDirection == "up") or (self.growthDirection == "down") then 
		self.Mask:SetHeight((percentage / 100) * self:GetHeight())
	else
		self.Mask:SetWidth((percentage / 100) * self:GetWidth())
	end
end

function wtHealthCap:BindColor(color)
	if color then
		self:SetBarColor(color.r, color.g, color.b, color.a)
	else
		self:SetBarColor(0, 0, 0, 1)
	end
end


function wtHealthCap:SetBarColor(r,g,b,a)
	self.Image:SetBackgroundColor(r or 0, g or 0, b or 0, a or 1)
end


function wtHealthCap:SetBarMedia(mediaId)
	Library.Media.SetTexture(self.Image, mediaId)
end


function wtHealthCap:SetBarTexture(texAddon, texFile)
	self.Image:SetTexture(texAddon, texFile)
end


function wtHealthCap:SetGrowthDirection(direction)

	self.growthDirection = direction or "right"
	self.Mask:ClearAll()

	if direction == "left" then
		self.Mask:SetPoint("TOPRIGHT", self, "TOPRIGHT")
		self.Mask:SetPoint("BOTTOM", self, "BOTTOM")
		self.Mask:SetWidth(self:GetWidth())
	elseif direction == "up" then
		self.Mask:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
		self.Mask:SetPoint("RIGHT", self, "RIGHT")
		self.Mask:SetHeight(self:GetHeight())
	elseif direction == "down" then
		self.Mask:SetPoint("TOPLEFT", self, "TOPLEFT")
		self.Mask:SetPoint("RIGHT", self, "RIGHT")
		self.Mask:SetHeight(self:GetHeight())
	else
		self.Mask:SetPoint("TOPLEFT", self, "TOPLEFT")
		self.Mask:SetPoint("BOTTOM", self, "BOTTOM")
		self.Mask:SetWidth(self:GetWidth())
	end
	
end	
