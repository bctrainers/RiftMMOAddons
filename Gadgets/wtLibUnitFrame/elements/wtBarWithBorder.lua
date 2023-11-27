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
local wtBarWithBorder = WT.Element:Subclass("BarWithBorder", "Frame")

wtBarWithBorder.ConfigDefinition = 
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
function wtBarWithBorder:Construct()

	local config = self.Configuration
	local unitFrame = self.UnitFrame
	
	self.Mask = UI.CreateFrame("Mask", "BarMask", self)
	self.Border = UI.CreateFrame("Mask","BarBorder", self)
	
	if (config.width) then self:SetWidth(config.width) end
	if (config.height) then self:SetHeight(config.height) end

	self:SetGrowthDirection(config.growthDirection or "right")
	
    self.fullBorder = config.fullBorder or false
	
	if not config.BarWithBorderColor then  
		self.BarWithBorderColor = {0,0,0,1}
	else 
		self.BarWithBorderColor = {config.BarWithBorderColor.r, config.BarWithBorderColor.g, config.BarWithBorderColor.b, config.BarWithBorderColor.a}
	end	
		
	if config.BorderColorBinding then
		  unitFrame:CreateBinding(config.BorderColorBinding, self, self.BindBorderColor, nil)	
	end
	
	self.Image = UI.CreateFrame("Texture", WT.UnitFrame.UniqueName(), self.Mask)
	
	if config.media then
		Library.Media.SetTexture(self.Image, config.media)
	elseif config.texAddon and config.texFile then
		self.Image:SetTexture(config.texAddon, config.texFile)
	end
	
	self.Image:SetPoint("TOPLEFT", self, "TOPLEFT")
	self.Image:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	 	
	unitFrame:CreateBinding(config.binding, self, self.BindPercent, 0)
		
	if config.colorBinding then
		self.UnitFrame:CreateBinding(config.colorBinding, self, self.BindColor, nil)
	end
	
	if config.backgroundColorBinding then
		self.UnitFrame:CreateBinding(config.backgroundColorBinding, self, self.BindbackgroundColor, nil)
	end
	
	if config.color then
		self:SetBarColor(config.color.r, config.color.g, config.color.b, config.color.a)
	end

	if config.backgroundColor then
		self:SetBackgroundColor(config.backgroundColor.r or 0, config.backgroundColor.g or 0, config.backgroundColor.b or 0, config.backgroundColor.a or 1)
	end
		
	--------------------------------------------------------------------------------
      local nameBase = unitFrame:GetName()
	  --local parent = self
	  --dump(parent)
	  local unitFrameLayer = unitFrame:GetLayer()  	

	  self.top = UI.CreateFrame("Frame", nameBase .."_TopBorder", self)
	  self.top:SetLayer(unitFrameLayer + 1)
	  self.top:ClearAll()
      self.top:SetPoint("BOTTOMLEFT", self.Border, "TOPLEFT", -1, 0)
      self.top:SetPoint("BOTTOMRIGHT", self.Border, "TOPRIGHT", 1, 0)
      self.top:SetHeight(1)
	  
	  self.bottom = UI.CreateFrame("Frame", nameBase .."_BottomBorder", self)
	  self.bottom:SetLayer(unitFrameLayer + 1)
      self.bottom:ClearAll()
      self.bottom:SetPoint("TOPLEFT", self.Border, "BOTTOMLEFT", -1, 0)
      self.bottom:SetPoint("TOPRIGHT", self.Border, "BOTTOMRIGHT", 1, 0)
      self.bottom:SetHeight(1)
	  
	  self.left = UI.CreateFrame("Frame", nameBase .."_LeftBorder", self)
      self.left:SetLayer(unitFrameLayer + 1)
      self.left:ClearAll()
      self.left:SetPoint("TOPRIGHT", self.Border, "TOPLEFT", 0, -1)
      self.left:SetPoint("BOTTOMRIGHT", self.Border, "BOTTOMLEFT", 0, 1)
      self.left:SetWidth(1)
	  
	  self.right = UI.CreateFrame("Frame", nameBase .."_RightBorder", self)
      self.right:SetLayer(unitFrameLayer + 1)
      self.right:ClearAll()
      self.right:SetPoint("TOPLEFT", self.Border, "TOPRIGHT", 0, -1)
      self.right:SetPoint("BOTTOMLEFT", self.Border, "BOTTOMRIGHT", 0, 1)
      self.right:SetWidth(1)

end

function wtBarWithBorder:BindPercent(percentage)
	if (self.growthDirection == "up") or (self.growthDirection == "down") then 
		self.Mask:SetHeight((percentage / 100) * self:GetHeight())
		
		if not self.fullBorder then
		self.Border:SetHeight(self:GetHeight())
		else self.Border:SetHeight((percentage / 100) * self:GetHeight()) end
	else
		self.Mask:SetWidth((percentage / 100) * self:GetWidth())
		if not self.fullBorder then
		self.Border:SetWidth(self:GetWidth())
		else self.Border:SetWidth((percentage / 100) * self:GetWidth()) end
	end

	if percentage > 0 then
	self.top:SetBackgroundColor(unpack(self.BarWithBorderColor))
	self.bottom:SetBackgroundColor(unpack(self.BarWithBorderColor))
	self.left:SetBackgroundColor(unpack(self.BarWithBorderColor))
	self.right:SetBackgroundColor(unpack(self.BarWithBorderColor))
	elseif percentage ~= 0 then
	self.top:SetBackgroundColor(unpack(self.BarWithBorderColor))
	self.bottom:SetBackgroundColor(unpack(self.BarWithBorderColor))
	self.left:SetBackgroundColor(unpack(self.BarWithBorderColor))
	self.right:SetBackgroundColor(unpack(self.BarWithBorderColor))
	else
	self.top:SetBackgroundColor( 0, 0, 0, 0)
	self.bottom:SetBackgroundColor( 0, 0, 0, 0)
	self.left:SetBackgroundColor(0, 0, 0, 0)
	self.right:SetBackgroundColor( 0, 0, 0, 0)
	end
end

function wtBarWithBorder:BindbackgroundColor(backgroundColor)
	if backgroundColor then
		self:SetBackgroundColor(backgroundColor.r or 0, backgroundColor.g or 0, backgroundColor.b or 0, backgroundColor.a or 0)
	end
end

function wtBarWithBorder:BindColor(color)
	if color then
		self:SetBarColor(color.r, color.g, color.b, color.a)
	else
		self:SetBarColor(0, 0, 0, 1)
	end
end


function wtBarWithBorder:SetBarColor(r,g,b,a)
	self.Image:SetBackgroundColor(r or 0, g or 0, b or 0, a or 1)
end


function wtBarWithBorder:SetBarMedia(mediaId)
	Library.Media.SetTexture(self.Image, mediaId)
end


function wtBarWithBorder:SetBarTexture(texAddon, texFile)
	self.Image:SetTexture(texAddon, texFile)
end


function wtBarWithBorder:SetGrowthDirection(direction)

	self.growthDirection = direction or "right"
	self.Mask:ClearAll()
    self.Border:ClearAll()
	
	if direction == "left" then
		self.Mask:SetPoint("TOPRIGHT", self, "TOPRIGHT")
		self.Mask:SetPoint("BOTTOM", self, "BOTTOM")
		self.Mask:SetWidth(self:GetWidth())
		
		self.Border:SetPoint("TOPRIGHT", self, "TOPRIGHT")
		self.Border:SetPoint("BOTTOM", self, "BOTTOM")
		self.Border:SetWidth(self:GetWidth())
	elseif direction == "up" then
		self.Mask:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
		self.Mask:SetPoint("RIGHT", self, "RIGHT")
		self.Mask:SetHeight(self:GetHeight())
		
		self.Border:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
		self.Border:SetPoint("RIGHT", self, "RIGHT")
		self.Border:SetHeight(self:GetHeight())
	elseif direction == "down" then
		self.Mask:SetPoint("TOPLEFT", self, "TOPLEFT")
		self.Mask:SetPoint("RIGHT", self, "RIGHT")
		self.Mask:SetHeight(self:GetHeight())
		
		self.Border:SetPoint("TOPLEFT", self, "TOPLEFT")
		self.Border:SetPoint("RIGHT", self, "RIGHT")
		self.Border:SetHeight(self:GetHeight())
	else
		self.Mask:SetPoint("TOPLEFT", self, "TOPLEFT")
		self.Mask:SetPoint("BOTTOM", self, "BOTTOM")
		self.Mask:SetWidth(self:GetWidth())
		
		self.Border:SetPoint("TOPLEFT", self, "TOPLEFT")
		self.Border:SetPoint("BOTTOM", self, "BOTTOM")
		self.Border:SetWidth(self:GetWidth())
	end
	
end	
