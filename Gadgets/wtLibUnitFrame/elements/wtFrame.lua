--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	WT.Frame
	
		Provides a Frame element

--]]

-- Create the class.
-- This will be automatically registered as an Element factory with the name "Label"
-- The base frame type is "Text"
local wtFrame = WT.Element:Subclass("Frame", "Frame")

-- The Construct method builds the element up. The element (self) is an instance of the relevant
-- UI.Frame as specified in the Subclass() call above ("Text")
function wtFrame:Construct()

	local config = self.Configuration
	local unitFrame = self.UnitFrame
		
	if config.color then 
		self:SetBackgroundColor(config.color.r or 0, config.color.g or 0, config.color.b or 0, config.color.a or 1)
	end

	if config.FrameAlphaBinding then
		unitFrame:CreateBinding(config.FrameAlphaBinding, self, self.BindFrameAlpha, nil)	
	end
	
	if config.colorBinding then
		unitFrame:CreateBinding(config.colorBinding, self, self.BindColor, nil)	
	end

	if config.width then self:SetWidth(config.width) end
	if config.height then self:SetHeight(config.height) end

	--------Add Border-------------------------------
    if config.border then
	local config = self.Configuration
	local unitFrame = self.UnitFrame
        local nameBase = unitFrame:GetName()
		local parent = unitFrame:GetParent()
		local unitFrameLayer = unitFrame:GetLayer()
	    self.width = width or 1
	    self.position = "outside"
	  	local width = self.width

	  self.top = UI.CreateFrame("Frame", nameBase .."_TopBorder", parent)
	--  self.top:SetBackgroundColor(config.color.r or 0, config.color.g or 0, config.color.b or 0, config.color.a or 1)
	  self.top:SetLayer(unitFrameLayer)
	  self.top:ClearAll()
      self.top:SetPoint("BOTTOMLEFT", unitFrame, "TOPLEFT", -width, 0)
      self.top:SetPoint("BOTTOMRIGHT", unitFrame, "TOPRIGHT", width, 0)
      self.top:SetHeight(width)
	  
	  self.bottom = UI.CreateFrame("Frame", nameBase .."_BottomBorder", parent)
	--  self.bottom:SetBackgroundColor(config.color.r or 0, config.color.g or 0, config.color.b or 0, config.color.a or 1)
	  self.bottom:SetLayer(unitFrameLayer)
      self.bottom:ClearAll()
      self.bottom:SetPoint("TOPLEFT", unitFrame, "BOTTOMLEFT", -width, 0)
      self.bottom:SetPoint("TOPRIGHT", unitFrame, "BOTTOMRIGHT", width, 0)
      self.bottom:SetHeight(width)
	  
	  self.left = UI.CreateFrame("Frame", nameBase .."_LeftBorder", parent)
	 -- self.left:SetBackgroundColor(config.color.r or 0, config.color.g or 0, config.color.b or 0, config.color.a or 1)
      self.left:SetLayer(unitFrameLayer)
      self.left:ClearAll()
      self.left:SetPoint("TOPRIGHT", unitFrame, "TOPLEFT", 0, -width)
      self.left:SetPoint("BOTTOMRIGHT", unitFrame, "BOTTOMLEFT", 0, width)
      self.left:SetWidth(width)
	  
	  self.right = UI.CreateFrame("Frame", nameBase .."_RightBorder", parent)
	  --self.right:SetBackgroundColor(config.color.r or 0, config.color.g or 0, config.color.b or 0, config.color.a or 1)
      self.right:SetLayer(unitFrameLayer)
      self.right:ClearAll()
      self.right:SetPoint("TOPLEFT", unitFrame, "TOPRIGHT", 0, -width)
      self.right:SetPoint("BOTTOMLEFT", unitFrame, "BOTTOMRIGHT", 0, width)
      self.right:SetWidth(width)

	  end
	  if config.BorderColorBinding then
		unitFrame:CreateBinding(config.BorderColorBinding, self, self.BindBorderColor, nil)	
		end
  -------------------------------------------------------------------------------------------------------
end


function wtFrame:BindColor(color)
	if color then
		self:SetBackgroundColor(color.r or 0, color.g or 0, color.b  or 0, color.a or 1) 
	else
		self:SetBackgroundColor(0, 0, 0, 1)
	end
end

function wtFrame:BindPercent(percentage)
		self:SetWidth((percentage / 100) * self:GetWidth())
end
---------------------Border Color------------------------------------------------------------------------------------------------------
function wtFrame:BindBorderColor(BorderColor)
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
-----------------------------------------------------------------------------------------------------------------------------
function wtFrame:BindFrameAlpha(FrameAlpha)
    if FrameAlpha then
		self:SetAlpha(FrameAlpha.alpha or 1)
	end	
end