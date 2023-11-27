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
local wtBar = WT.Element:Subclass("Bar", "Frame")

wtBar.ConfigDefinition = 
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
function wtBar:Construct()

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
	
	if config.BorderTextureAggroVisibleBinding then
		  unitFrame:CreateBinding(config.BorderTextureAggroVisibleBinding, self, self.BindBorderTextureAggroVisible, nil)	
	end
	  
	if config.BorderColorBinding then
		  unitFrame:CreateBinding(config.BorderColorBinding, self, self.BindBorderColor, nil)	
	end
	 
	if config.BorderTextureTargetVisibleBinding then
		  unitFrame:CreateBinding(config.BorderTextureTargetVisibleBinding, self, self.BindBorderTextureTargetVisible, nil)	
	end
	  	
	--------------------------------------------------------------------------------
    if config.border then
	local config = self.Configuration
	local unitFrame = self.Mask
        local nameBase = unitFrame:GetName()
		local parent = unitFrame:GetParent()
		local unitFrameLayer = unitFrame:GetLayer()
	    local  width = self.width or 1.25
	    --self.position = "outside"  	  	

	  self.top = UI.CreateFrame("Frame", nameBase .."_TopBorder", parent)
	  self.top:SetLayer(unitFrameLayer)
	  self.top:ClearAll()
      self.top:SetPoint("BOTTOMLEFT", unitFrame, "TOPLEFT", -width, 0)
      self.top:SetPoint("BOTTOMRIGHT", unitFrame, "TOPRIGHT", width, 0)
      self.top:SetHeight(width)

	  self.bottom = UI.CreateFrame("Frame", nameBase .."_BottomBorder", parent)
	  self.bottom:SetLayer(unitFrameLayer)
      self.bottom:ClearAll()
      self.bottom:SetPoint("TOPLEFT", unitFrame, "BOTTOMLEFT", -width, 0)
      self.bottom:SetPoint("TOPRIGHT", unitFrame, "BOTTOMRIGHT", width, 0)
      self.bottom:SetHeight(width)
	  
	  self.left = UI.CreateFrame("Frame", nameBase .."_LeftBorder", parent)
      self.left:SetLayer(unitFrameLayer)
      self.left:ClearAll()
      self.left:SetPoint("TOPRIGHT", unitFrame, "TOPLEFT", 0, -width)
      self.left:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMLEFT", 0, width)
      self.left:SetWidth(width)
	  
	  self.right = UI.CreateFrame("Frame", nameBase .."_RightBorder", parent)
      self.right:SetLayer(unitFrameLayer)
      self.right:ClearAll()
      self.right:SetPoint("TOPLEFT", unitFrame, "TOPRIGHT", 0, -width)
      self.right:SetPoint("BOTTOMLEFT", unitFrame, "BOTTOMRIGHT", 0, width)
      self.right:SetWidth(width)
	  --------------------------------------------TextureTarget----------------------------------------------------------
			if config.borderTextureTarget then
			local config = self.Configuration
			local TextureTargetLayer = unitFrame:GetLayer() + 1	  	

			  self.topTextureTarget = UI.CreateFrame("Texture", nameBase .."_TopTextureTargetBorder", self.top )
			  self.topTextureTarget:SetLayer(TextureTargetLayer)
			  self.topTextureTarget:ClearAll()
			  self.topTextureTarget:SetPoint("BOTTOMLEFT", self.top, "TOPLEFT", 0, 1)
			  self.topTextureTarget:SetPoint("BOTTOMRIGHT", self.top, "TOPRIGHT", 0, 1)
			  self.topTextureTarget:SetHeight(4)
			  self.topTextureTarget:SetTexture("Gadgets", "img/wb.png")
			  self.topTextureTarget:SetVisible(false)

			  self.bottomTextureTarget = UI.CreateFrame("Texture", nameBase .."_BottomTextureTargetBorder", self.bottom)
			  self.bottomTextureTarget:SetLayer(TextureTargetLayer)
			  self.bottomTextureTarget:ClearAll()
			  self.bottomTextureTarget:SetPoint("TOPLEFT", self.bottom, "BOTTOMLEFT", 0, -1)
			  self.bottomTextureTarget:SetPoint("TOPRIGHT", self.bottom, "BOTTOMRIGHT", 0, -1)
			  self.bottomTextureTarget:SetHeight(4)
			  self.bottomTextureTarget:SetTexture("Gadgets", "img/wt.png")
			  self.bottomTextureTarget:SetVisible(false)
			  
			  self.leftTextureTarget = UI.CreateFrame("Texture", nameBase .."_LeftTextureTargetBorder", self.left)
			  self.leftTextureTarget:SetLayer(TextureTargetLayer)
			  self.leftTextureTarget:ClearAll()
			  self.leftTextureTarget:SetPoint("TOPRIGHT", self.left, "TOPLEFT", 1, 0)
			  self.leftTextureTarget:SetPoint("BOTTOMRIGHT", self.left, "BOTTOMLEFT", 1, 0)
			  self.leftTextureTarget:SetWidth(4)
			  self.leftTextureTarget:SetTexture("Gadgets", "img/wr.png")
			  self.leftTextureTarget:SetVisible(false)
			  
			  self.rightTextureTarget = UI.CreateFrame("Texture", nameBase .."_RightTextureTargetBorder", self.right)
			  self.rightTextureTarget:SetLayer(TextureTargetLayer)
			  self.rightTextureTarget:ClearAll()
			  self.rightTextureTarget:SetPoint("TOPLEFT", self.right, "TOPRIGHT", -1, 0)
			  self.rightTextureTarget:SetPoint("BOTTOMLEFT", self.right, "BOTTOMRIGHT", -1, 0)
			  self.rightTextureTarget:SetWidth(4)
			  self.rightTextureTarget:SetTexture("Gadgets", "img/wl.png")
			  self.rightTextureTarget:SetVisible(false)
			  end
  --------------------------------------------TextureAggro-----------------------------------------------------------
			if config.borderTextureAggro then
			local config = self.Configuration
			local TextureAggro = unitFrame:GetLayer() + 2 	  	

			  self.topTextureAggro = UI.CreateFrame("Texture", nameBase .."_topTextureAggroBorder", self.top)
			  self.topTextureAggro:SetLayer(TextureAggro)
			  self.topTextureAggro:ClearAll()
			  self.topTextureAggro:SetPoint("BOTTOMLEFT", self.top, "TOPLEFT", 0, 0)
			  self.topTextureAggro:SetPoint("BOTTOMRIGHT", self.top, "TOPRIGHT", 0, 0)
			  self.topTextureAggro:SetHeight(5)
			  self.topTextureAggro:SetTexture("Gadgets", "img/rt.png")
			  self.topTextureAggro:SetVisible(false)

			  self.bottomTextureAggro = UI.CreateFrame("Texture", nameBase .."_BottomTextureAggroBorder", self.bottom)
			  self.bottomTextureAggro:SetLayer(TextureAggro)
			  self.bottomTextureAggro:ClearAll()
			  self.bottomTextureAggro:SetPoint("TOPLEFT", self.bottom, "BOTTOMLEFT", 0, 0)
			  self.bottomTextureAggro:SetPoint("TOPRIGHT", self.bottom, "BOTTOMRIGHT", 0, 0)
			  self.bottomTextureAggro:SetHeight(5)
			  self.bottomTextureAggro:SetTexture("Gadgets", "img/rb.png")
			  self.bottomTextureAggro:SetVisible(false)
			  
			  self.leftTextureAggro = UI.CreateFrame("Texture", nameBase .."_LeftTextureAggroBorder", self.left)
			  self.leftTextureAggro:SetLayer(TextureAggro)
			  self.leftTextureAggro:ClearAll()
			  self.leftTextureAggro:SetPoint("TOPRIGHT", self.left, "TOPLEFT", 0, 0)
			  self.leftTextureAggro:SetPoint("BOTTOMRIGHT", self.left, "BOTTOMLEFT", 0, 0)
			  self.leftTextureAggro:SetWidth(5)
			  self.leftTextureAggro:SetTexture("Gadgets", "img/rr.png")
			  self.leftTextureAggro:SetVisible(false)
			  
			  self.rightTextureAggro = UI.CreateFrame("Texture", nameBase .."_RightTextureAggroBorder", self.right)
			  self.rightTextureAggro:SetLayer(TextureAggro)
			  self.rightTextureAggro:ClearAll()
			  self.rightTextureAggro:SetPoint("TOPLEFT", self.right, "TOPRIGHT", 0, 0)
			  self.rightTextureAggro:SetPoint("BOTTOMLEFT", self.right, "BOTTOMRIGHT", 0, 0)
			  self.rightTextureAggro:SetWidth(5)
			  self.rightTextureAggro:SetTexture("Gadgets", "img/rl.png")
			  self.rightTextureAggro:SetVisible(false)
			  end
	end
end
--------------------------Border color-----------------------------------------------------------------
function wtBar:BindBorderColor(BorderColor)
	if BorderColor then
	     self.top:SetBackgroundColor(BorderColor.r or 0, BorderColor.g or 0, BorderColor.b or 0, BorderColor.a or 0)
		 	end
	if BorderColor then
		 self.bottom:SetBackgroundColor(BorderColor.r or 0, BorderColor.g or 0, BorderColor.b or 0, BorderColor.a or 0)
		 end
	if BorderColor then
		 self.left:SetBackgroundColor(BorderColor.r or 0, BorderColor.g or 0, BorderColor.b or 0, BorderColor.a or 0)
		 end
	if BorderColor then
         self.right:SetBackgroundColor(BorderColor.r or 0, BorderColor.g or 0, BorderColor.b or 0, BorderColor.a or 0)
	end
end
-----------------------------------------------------------------------------------------------------------------------
function wtBar:BindBorderTextureAggroVisible(BorderTextureAggroVisible)
	if BorderTextureAggroVisible == true then
		  self.topTextureAggro:SetVisible(BorderTextureAggroVisible or true)
		  self.bottomTextureAggro:SetVisible(BorderTextureAggroVisible or true)
		  self.leftTextureAggro:SetVisible(BorderTextureAggroVisible or true)
		  self.rightTextureAggro:SetVisible(BorderTextureAggroVisible or true)
		else  
		  self.topTextureAggro:SetVisible(BorderTextureAggroVisible or false)
		  self.bottomTextureAggro:SetVisible(BorderTextureAggroVisible or false)
		  self.leftTextureAggro:SetVisible(BorderTextureAggroVisible or false)
		  self.rightTextureAggro:SetVisible(BorderTextureAggroVisible or false)
	end
end

function wtBar:BindBorderTextureTargetVisible(BorderTextureTargetVisible)
	if BorderTextureTargetVisible == true then
		  self.topTextureTarget:SetVisible(BorderTextureTargetVisible or true)
		  self.bottomTextureTarget:SetVisible(BorderTextureTargetVisible or true)
		  self.leftTextureTarget:SetVisible(BorderTextureTargetVisible or true)
		  self.rightTextureTarget:SetVisible(BorderTextureTargetVisible or true)
		else  
		  self.topTextureTarget:SetVisible(BorderTextureTargetVisible or false)
		  self.bottomTextureTarget:SetVisible(BorderTextureTargetVisible or false)
		  self.leftTextureTarget:SetVisible(BorderTextureTargetVisible or false)
		  self.rightTextureTarget:SetVisible(BorderTextureTargetVisible or false)
	end
end

function wtBar:BindPercent(percentage)
	if (self.growthDirection == "up") or (self.growthDirection == "down") then 
		self.Mask:SetHeight((percentage / 100) * self:GetHeight())
	else
		self.Mask:SetWidth((percentage / 100) * self:GetWidth())
	end
end

function wtBar:BindbackgroundColor(backgroundColor)
	if backgroundColor then
		self:SetBackgroundColor(backgroundColor.r or 0, backgroundColor.g or 0, backgroundColor.b or 0, backgroundColor.a or 0)
	end
end

function wtBar:BindColor(color)
	if color then
		self:SetBarColor(color.r, color.g, color.b, color.a)
	else
		self:SetBarColor(0, 0, 0, 1)
	end
end


function wtBar:SetBarColor(r,g,b,a)
	self.Image:SetBackgroundColor(r or 0, g or 0, b or 0, a or 1)
end


function wtBar:SetBarMedia(mediaId)
	Library.Media.SetTexture(self.Image, mediaId)
end


function wtBar:SetBarTexture(texAddon, texFile)
	self.Image:SetTexture(texAddon, texFile)
end


function wtBar:SetGrowthDirection(direction)

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
