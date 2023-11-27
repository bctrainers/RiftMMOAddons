local toc, data = ...
local AddonId = toc.identifier

-- Frame Configuration Options --------------------------------------------------
local HP_Text = WT.UnitFrame:Template("HP_Text")
HP_Text.Configuration.Name = "HP text"
HP_Text.Configuration.RaidSuitable = false
HP_Text.Configuration.UnitSuitable = true
HP_Text.Configuration.FrameType = "Frame"
HP_Text.Configuration.Width = 40
HP_Text.Configuration.Height = 20
HP_Text.Configuration.Resizable = { 10, 5, 100, 50 }
HP_Text.Configuration.SupportsOwnBuffsPanel = false
HP_Text.Configuration.SupportsOwnDebuffsPanel = false
HP_Text.Configuration.SupportsExcludeBuffsPanel = false
HP_Text.Configuration.SupportsExcludeCastsPanel = false
HP_Text.Configuration.SupportsShowRadius = false
HP_Text.Configuration.SupportsShowCombo = false
HP_Text.Configuration.SupportsShowRankIconPanel = false
--------------------------------------------------------------
function HP_Text:Construct(options)
	local template =
	{
		elements = 
		{
		--[[
			{
				id="labelhealth", type="Label", parent="frameBackdrop", layer=20,
				attach = {{ point="CENTERLEFT", element="frame", targetPoint="CENTERLEFT", offsetX=0, offsetY=0 }},
				visibilityBinding="health",
				text=" {health} | {healthMax}", default="", fontSize=12, outline=true,
			},
		]]	
			{
				id="labelhealthPercent", type="Label", parent="frameBackdrop", layer=20,
				attach = {{ point="CENTER", element="frame", targetPoint="CENTER", offsetX=0, offsetY=0   }},
				visibilityBinding="health",
				text="{healthPercent}%", default="", fontSize=12, outline=true, font="Republika", 
			},		
		}
	}
	
	for idx,element in ipairs(template.elements) do
	    local showElement = true	
		if showElement then
			self:CreateElement(element)
		end
	end

	self:EventAttach(
		Event.UI.Layout.Size,
		function(el)
			local newWidth = self:GetWidth()
			local newHeight = self:GetHeight()/2
			local fracWidth = newWidth / HP_Text.Configuration.Width
			local fracHeight = newHeight / HP_Text.Configuration.Height
			local fracMin = math.min(fracWidth, fracHeight)
			local fracMax = math.max(fracWidth, fracHeight)
			local fontSize = self.Elements.labelhealthPercent
			fontSize:SetFontSize(14 * fracWidth)
		end,
		"LayoutSize")
	
	self:SetSecureMode("restricted")
	self:SetMouseoverUnit(self.UnitSpec)
	
 end  