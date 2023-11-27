--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	WT.Label
	
		Provides a Label element, which is used to display text within a UnitFrame.
		
		The text must contain tokens that map to properties on the associated unit. If a value is unavailable
		for ANY token, the default value is displayed instead. If the text contains no tokens, no bindings will
		ever fire and the default text will always be used instead.
		
		Example: Setting text = "{health}/{healthMax} ({healthPercent}%)", with a default of "", will give you a label that
		makes sense over the top of a health bar. If any of the values are not available (generally because no unit is available),
		the label displays nothing (the default).

--]]

-- Create the class.
-- This will be automatically registered as an Element factory with the name "Label"
-- The base frame type is "Text"
local wtLabel = WT.Element:Subclass("Label", "Text")

-- The Construct method builds the element up. The element (self) is an instance of the relevant
-- UI.Frame as specified in the Subclass() call above ("Text")
function wtLabel:Construct()

	local config = self.Configuration
	local unitFrame = self.UnitFrame

	-- Validate configuration
	if not config.text then error("Label missing required configuration item: text") end
	
	if config.fontSize then
		self:SetFontSize(config.fontSize)
	end
	
	if config.color then
		self:SetFontColor(config.color.r or 0, config.color.g or 0, config.color.b or 0, config.color.a or 1) 
	end
	
	if config.colorBinding then
		unitFrame:CreateBinding(config.colorBinding, self, self.BindColor, nil)
	end
	
	if config.maxLength then
		self.maxLength = config.maxLength
	else
		self.maxLength = nil
	end 
	
	if config.font then
		local fontEntry = Library.Media.GetFont(config.font)
		if fontEntry then
			self:SetFont(fontEntry.addonId, fontEntry.filename)
		end
	end
	
	if config.outline then
		self:SetEffectGlow({ strength = 3 })
	end
	
	if config.outline2 then
		self:SetEffectGlow({
		blurX = 4,			--Controls how much blurring exists along the X axis. Defaults to 2.
		blurY = 4,			--Controls how much blurring exists along the Y axis. Defaults to 2.
		colorR = 0,		--Controls the red channel of the glow effect. Defaults to 0.
		colorG = 0,		--Controls the green channel of the glow effect. Defaults to 0.
		colorB = 0,		--Controls the blue channel of the glow effect. Defaults to 0.
		colorA = 1,			--Controls the alpha channel of the glow effect. Defaults to 1.
		offsetX = 0,		--Controls the glow offset along the X axis. Defaults to 0.
		offsetY = 0,		--Controls the glow offset along the Y axis. Defaults to 0.
		strength = 3,		--Controls the strength of the glow. Defaults to 1. 
		})
	end
	
	self.SetLabelText = 
		function(frame, text)
			self:SetText(text)
		end
	--local len = self:len()
	unitFrame:CreateTokenBinding(config.text, self, self.SetLabelText, config.default or "", self.maxLength)
	
	if config.linkedHeightElement then
		self.linkedHeightElement = unitFrame.Elements[config.linkedHeightElement]
		self.linkedHeightScale = config.linkedHeightScale or 0.6
	end

	if self.linkedHeightElement then
		if not self.linkedHeightElement.linkedElements then self.linkedHeightElement.linkedElements = {} end
		table.insert(self.linkedHeightElement.linkedElements, self)
		self.linkedHeightElement.Event.Size = 
			function()
				local newHeight = self.linkedHeightElement:GetHeight()
				if newHeight ~= self.oldLinkedHeight then
----------------------------------------------------------------------------------------------------------------
					--for idx, el in ipairs(self.linkedHeightElement.linkedElements) do
					--	el:SetFontSize(newHeight * self.linkedHeightScale)
					--end
----------------------------------------------------------------------------------------------------------------					
					self.oldLinkedHeight = newHeight
				end
			end
	end
	
end

function wtLabel:BindColor(color)
	if color then
		self:SetFontColor(color.r or 0, color.g or 0, color.b or 0, color.a or 1)
	else
		self:SetFontColor(1, 1, 1, 1)
	end
end

-- Fluent Configuration Methods

function wtLabel.Text(template, value)
	template.current.text = value
	return template
end

-- Configuration Dialog for this element type

function wtLabel:BuildConfig(dialog)
	dialog:TextField(self.id, "Label Text", self.text)
end
