local toc, data = ...
local AddonId = toc.identifier

-- Local config options ---------------------------------------------------------
local scale = 0.5
local manaOrbWidth = 256 * scale
local manaOrbHeight = 256 * scale
---------------------------------------------------------------------------------

-- Frame Configuration Options --------------------------------------------------
local ManaOrb = WT.UnitFrame:Template("ManaOrb")
ManaOrb.Configuration.Name = "Mana Orb Unit Frame"
ManaOrb.Configuration.RaidSuitable = false
ManaOrb.Configuration.UnitSuitable = true
ManaOrb.Configuration.FrameType = "Frame"
ManaOrb.Configuration.Width = manaOrbWidth
ManaOrb.Configuration.Height = manaOrbHeight
---------------------------------------------------------------------------------


function ManaOrb:Construct(options)

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
				}, visibilityBinding="id", binding="resourcePercent", growthDirection="up", texAddon=AddonId, texFile="img/orb_blue.tga", height=manaOrbHeight, width=manaOrbWidth,		
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
				id="manaPercent", type="Label", parent="frame", layer=14,
				attach = 
				{ 
					{ point="CENTER", element="frame", targetPoint="CENTER" },
				}, visibilityBinding="id", text="{resourcePercent}%",fontSize=24,		
			}, 
			{
				id="name", type="Label", parent="frame", layer=18,
				attach = 
				{ 
					{ point="BOTTOMCENTER", element="manaPercent", targetPoint="TOPCENTER" },
				}, visibilityBinding="id", text="{resourceText}",fontSize=13,		
			}, 
			{
				id="mana", type="Label", parent="frame", layer=18,
				attach = 
				{ 
					{ point="TOPCENTER", element="manaPercent", targetPoint="BOTTOMCENTER" },
				}, visibilityBinding="id", text="{resource}",fontSize=13,		
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
