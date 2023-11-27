local toc, data = ...
local AddonId = toc.identifier

-- Local config options ---------------------------------------------------------
local scale = 1.0
local LifeOrbWidth = 256 * scale
local LifeOrbHeight = 256 * scale
---------------------------------------------------------------------------------

-- Frame Configuration Options --------------------------------------------------
local LifeOrb = WT.UnitFrame:Template("LifeOrb")
LifeOrb.Configuration.Name = "Health+Mana+lvl Orb Unit Frame"
LifeOrb.Configuration.RaidSuitable = false
LifeOrb.Configuration.UnitSuitable = true
LifeOrb.Configuration.FrameType = "Frame"
LifeOrb.Configuration.Width = LifeOrbWidth
LifeOrb.Configuration.Height = LifeOrbHeight
LifeOrb.Configuration.Resizable = { LifeOrbWidth / 4, LifeOrbHeight / 4, LifeOrbWidth * 2, LifeOrbHeight * 2 } 
---------------------------------------------------------------------------------


function LifeOrb:Construct(options)

	local template =
	{
		elements = 
		{
	
	-- HP ORB =====================================================================================
			-- ORB back BG
			{
				id="orbBACK", type="Image", parent="frame", layer=10, alpha=1,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" } 
				}, 				
				visibilityBinding="id", texAddon = AddonId, texFile = "img/lifeOrb_back.png"	
			}, 
			{
				id="orbBackBlack", type="Image", parent="frame", layer=11, alpha=1,
				attach = 
				{ 
					{ point="CENTER", element="frame", targetPoint="CENTER", offsetX=0, offsetY=0 } 
				}, 
				visibilityBinding="id", 
				texAddon=AddonId, texFile="img/orb_Back.tga",
				height=149, width=149,		
			},
			-- ORB filling BG
			{
				id="orbHealth", type="Bar", parent="frame", layer=12, alpha=1,
				attach = 
				{ 
					{ point="CENTER", element="frame", targetPoint="CENTER", offsetX=0, offsetY=0 } 
				}, 
				visibilityBinding="id", 
				binding="healthPercent",
				growthDirection="up",
				texAddon=AddonId, texFile="img/orb_red.tga",
				--media="orb_red.tga", 
				height=149, width=149,		
			},

			{
				id="orbHealpCap", type="Bar", parent="frame", layer=12, alpha=1,
				attach = 
				{ 
					{ point="CENTER", element="frame", targetPoint="CENTER", offsetX=0, offsetY=0 } 
				}, 				
				visibilityBinding="healthCap",
				binding="healthCapPercent", growthDirection="down",
				texAddon=AddonId, texFile="img/orb_healthCap.tga",	
				height=149, width=149,	
			},
			{
				id="orbAbsord", type="Bar", parent="frame", layer=13, alpha=1,
				attach = 
				{ 
					{ point="CENTER", element="frame", targetPoint="CENTER", offsetX=0, offsetY=5 } 
				},
				visibilityBinding="id", 
				binding="health", 
				binding="absorbPercent", 
				growthDirection="up",
				texAddon = "Rift", texFile = "round_progbar.png.dds"	,
				height=240, width=240,		
			},
			-- ORB ring on top
			{
				id="orbRING", type="Image", parent="frame", layer=13, alpha=1,
				attach = 
				{ 
					{ point="CENTER", element="frame", targetPoint="CENTER", offsetX=0, offsetY=0 } 
				}, 				
				visibilityBinding="id", texAddon = "Rift", texFile = "round_yellow_base.png.dds",
				height=150, width=150,					
			},
			-- HP (%)
			{
				id="healthPERCENT", type="Label", parent="frame", layer=14,
				attach = 
				{ 
					{ point="CENTER", element="orbHealth", targetPoint="CENTER", offsetX=0, offsetY=-5 },
				}, visibilityBinding="id", text="{healthPercent}%",fontSize=36,	outline=true
			}, 
			
			-- HP (num)
			{
				id="healthNUM", type="Label", parent="frame", layer=15,
				attach = 
				{ 
					{ point="TOPCENTER", element="healthPERCENT", targetPoint="CENTER", offsetX=0, offsetY=15 },
				}, visibilityBinding="id", text="{health}",fontSize=16,	outline=true
			},
	-- LVL + NAME =====================================================================================
		--[[	{
				id="TxtName", type="Label", parent="frame", layer=20,
				attach = 
				{ 
					{ point="TOPCENTER", element="orbBACK", targetPoint="BOTTOMCENTER", offsetX=30, offsetY=-20 },
				}, visibilityBinding="id", text="{nameShort} - {level}",fontSize=20, outline=true
			},]]
		}
	}
	
	WT.UnitFrame.EnableResizableTemplate(self, LifeOrbWidth, LifeOrbHeight, template.elements)
	
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
