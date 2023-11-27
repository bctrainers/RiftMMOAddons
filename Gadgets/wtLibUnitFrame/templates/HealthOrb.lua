local toc, data = ...
local AddonId = toc.identifier

-- Local config options ---------------------------------------------------------
local scale = 0.5
local healthOrbWidth = 256 * scale
local healthOrbHeight = 256 * scale
---------------------------------------------------------------------------------

-- Frame Configuration Options --------------------------------------------------
local HealthOrb = WT.UnitFrame:Template("HealthOrb")
HealthOrb.Configuration.Name = "Health Orb Unit Frame"
HealthOrb.Configuration.RaidSuitable = false
HealthOrb.Configuration.UnitSuitable = true
HealthOrb.Configuration.FrameType = "Frame"
HealthOrb.Configuration.Width = healthOrbWidth
HealthOrb.Configuration.Height = healthOrbHeight
---------------------------------------------------------------------------------


function HealthOrb:Construct(options)

	local template =
	{
		elements = 
		{
			{
				id="frameBackdrop", type="Image", parent="frame", layer=6,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" } 
				}, 				
				visibilityBinding="id", texAddon = AddonId, texFile = "img/orb_back2.tga"		
			}, 
			{
				id="innerShadow", type="Image", parent="frame", layer=6, alpha=0.6,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" } 
				}, 				
				visibilityBinding="id", texAddon = AddonId, texFile = "img/orbInnerShadow.tga"		
			}, 
			{
				id="green", type="Bar", parent="frame", layer=10, alpha=0.8,
				attach = 
				{ 
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" } 
				}, visibilityBinding="id", binding="healthPercent", growthDirection="up",
				media="wtOrbGreen", 
				-- texAddon=AddonId, texFile="img/orb_green.tga", 
				height=healthOrbHeight, width=healthOrbWidth,		
			}, 
			{
				id="gloss", type="Image", parent="frame", layer=14,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" } 
				}, visibilityBinding="id", texAddon = AddonId, texFile = "img/orb_gloss.tga"		
			}, 
			{
				id="healthPercent", type="Label", parent="frame", layer=14,
				attach = 
				{ 
					{ point="CENTER", element="frame", targetPoint="CENTER" },
				}, visibilityBinding="id", text="{healthPercent}%",fontSize=24,		
			}, 
			{
				id="name", type="Label", parent="frame", layer=18,
				attach = 
				{ 
					{ point="BOTTOMCENTER", element="healthPercent", targetPoint="TOPCENTER", offsetX=0, offsetY=0 },
				}, visibilityBinding="id", text="{nameShort}",fontSize=13,		
			}, 
			{
				id="health", type="Label", parent="frame", layer=18,
				attach = 
				{ 
					{ point="TOPCENTER", element="healthPercent", targetPoint="BOTTOMCENTER", offsetX=0, offsetY=0 },
				}, visibilityBinding="id", text="{health}",fontSize=13,		
			}, 
		}
	}
	
	for idx,element in ipairs(template.elements) do
		self:CreateElement(element) 
	end
	
	self:SetSecureMode("restricted")
	self:SetMouseoverUnit(self.UnitSpec)
	self:EventMacroSet(Event.UI.Input.Mouse.Left.Click, "target @" .. self.UnitSpec)
	self:EventAttach(Event.UI.Input.Mouse.Right.Click, function(self, h)
		if self.UnitId then Command.Unit.Menu(self.UnitId) end
	end, "Event.UI.Input.Mouse.Right.Click")
	
end
