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
local wtCanvas = WT.Element:Subclass("Canvas", "Canvas")

wtCanvas.ConfigDefinition = 
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
function wtCanvas:Construct()

	local config = self.Configuration
	local unitFrame = self.unitFrame

	
	config.HP_bar_color = {0.07, 0.07, 0.07, 0.85}
	config.HP_bar_backgroundColor = {0.66, 0.22, 0.22, 1 }	
	config.width = config.width or 259 
	config.height = config.height or 15 
	config.HP_bar_angle = config.HP_bar_angle or 0
	config.HP_bar_color = config.HP_bar_color or {0.07, 0.07, 0.07, 0.85}
	config.HP_bar_backgroundColor = config.HP_bar_backgroundColor or  {0.66, 0.22, 0.22, 1 }
	config.HP_bar_insert = config.HP_bar_insert or false


	config.canvasSettings = {
		angle_HP = config.HP_bar_angle or 0,
		unitFrameIndent = 0,
		strokeBack = { r = 0, g = 0, b = 0, a = 1, thickness = 1 },
		stroke_HP = { r = 0, g = 0, b = 0, a = 1, thickness = 1 },
		stroke_HealthCap = { r = 0, g = 0, b = 0, a = 1, thickness = 0},
		fill_HP = { type = "solid", r = config.HP_bar_color[1], g = config.HP_bar_color[2], b = config.HP_bar_color[3], a = config.HP_bar_color[4] },
		fill_HP_back = { type = "solid", r = config.HP_bar_backgroundColor[1], g = config.HP_bar_backgroundColor[2], b = config.HP_bar_backgroundColor[3], a = config.HP_bar_backgroundColor[4] },
		
	}
	
	self.Mask = UI.CreateFrame("Mask", "BarMask", self)
	
	self.Mask:SetPoint("TOPLEFT", self, "TOPLEFT", config.canvasSettings.unitFrameIndent, config.canvasSettings.unitFrameIndent)
	self.Mask:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -config.canvasSettings.unitFrameIndent, -config.canvasSettings.unitFrameIndent)
	--self.Mask:SetWidth(config.width)
	--self.Mask:SetHeight(config.height)
	unitFrame:CreateBinding(config.binding, self, self.BindPercent, 0)
	--if (config.width) then self:SetWidth(config.width) end
	--if (config.height) then self:SetHeight(config.height) end
	self:SetWidth(config.width)
	self:SetHeight(config.height)
	self.bar_HP = UI.CreateFrame("Canvas", "bar_HP", self.Mask)
	self.bar_HP:SetPoint("TOPLEFT", self.Mask, "TOPLEFT")
	self.bar_HP:SetPoint("BOTTOMRIGHT", self.Mask, "BOTTOMRIGHT")
	
	--self:SetGrowthDirection(config.growthDirection or "right")
	
	
		local tg_HP = math.tan(config.canvasSettings.angle_HP * math.pi / 180)
		local offset_HP = tg_HP * self:GetHeight() / self:GetWidth() / 2
		local indentOffset_HP = tg_HP * config.canvasSettings.unitFrameIndent / self:GetWidth()

		config.canvasSettings.path_HP = { 
			{ xProportional = math.abs(offset_HP) - offset_HP, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_HP) - offset_HP, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_HP) + offset_HP, yProportional = 1 },
			{ xProportional = math.abs(offset_HP) + offset_HP, yProportional = 1 },
			{ xProportional = math.abs(offset_HP) - offset_HP, yProportional = 0 }
		}
		config.canvasSettings.path_HPmask = { 
			{ xProportional = math.abs(offset_HP) - offset_HP + indentOffset_HP, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_HP) - offset_HP + indentOffset_HP, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset_HP) + offset_HP - indentOffset_HP, yProportional = 1 },
			{ xProportional = math.abs(offset_HP) + offset_HP - indentOffset_HP, yProportional = 1 },
			{ xProportional = math.abs(offset_HP) - offset_HP + indentOffset_HP, yProportional = 0 }
		}
		
		self:SetShape(config.canvasSettings.path_HP, config.canvasSettings.fill_HP, config.canvasSettings.strokeBack)
		self.Mask:SetShape(config.canvasSettings.path_HPmask)
		self.bar_HP:SetShape(config.canvasSettings.path_HPmask, config.canvasSettings.fill_HP_back, config.canvasSettings.stroke_HP)

	
	--[[	
	if config.colorBinding then
		self.unitFrame:CreateBinding(config.colorBinding, self, self.BindColor, nil)
	end
	
	if config.backgroundColorBinding then
		self.unitFrame:CreateBinding(config.backgroundColorBinding, self, self.BindbackgroundColor, nil)
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
	]]
end

function wtCanvas:BindBorderColor(BorderColor)
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

function wtCanvas:BindBorderTextureAggroVisible(BorderTextureAggroVisible)
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

function wtCanvas:BindBorderTextureTargetVisible(BorderTextureTargetVisible)
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

function wtCanvas:BindPercent(percentage)
	if (self.growthDirection == "up") or (self.growthDirection == "down") then 
		self.Mask:SetHeight((1 - percentage / 100) * self:GetHeight())
	else
		self.Mask:SetWidth((1 - percentage / 100) * self:GetWidth())
	end
	--[[
	if healthPercent then
		if unitFrame.bar_HP and unitFrame.Backdrop_HP then	
		local unit = unitFrame.Unit
			local delta = (1 - healthPercent) / 100 * (unitFrame.realWidth_HP + 1)
			if unitFrame.HP_bar_insert == false then delta = -delta end
			if healthPercent >= 99.7 then delta = unitFrame.realWidth_HP + 1  end
			unitFrame.bar_HP:SetPoint("TOPLEFT", unitFrame.barMask_HP, "TOPLEFT", delta, 0)
			unitFrame.bar_HP:SetPoint("BOTTOMRIGHT", unitFrame.barMask_HP, "BOTTOMRIGHT", delta, 0)

			unitFrame.bar_HP:SetVisible(true)
			unitFrame.Backdrop_HP:SetVisible(true)
	else
		if unitFrame.bar_HP and unitFrame.Backdrop_HP then
			unitFrame.bar_HP:SetVisible(false)
			unitFrame.Backdrop_HP:SetVisible(false)
		end
	end	
	]]
end

function wtCanvas:BindbackgroundColor(backgroundColor)
	if backgroundColor then
		self:SetBackgroundColor(backgroundColor.r or 0, backgroundColor.g or 0, backgroundColor.b or 0, backgroundColor.a or 0)
	end
end

function wtCanvas:BindColor(color)
	if color then
		self:SetBarColor(color.r, color.g, color.b, color.a)
	else
		self:SetBarColor(0, 0, 0, 1)
	end
end


function wtCanvas:SetBarColor(r,g,b,a)
	self.Image:SetBackgroundColor(r or 0, g or 0, b or 0, a or 1)
end

function wtCanvas:SetBarMedia(mediaId, border)
	Library.Media.SetTexture(self.Image, mediaId)
end


function wtCanvas:SetBarTexture(texAddon, texFile)
	self.Image:SetTexture(texAddon, texFile)
end


function wtCanvas:SetGrowthDirection(direction)

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
