local toc, data = ...
local AddonId = toc.identifier

-- Local config options ---------------------------------------------------------
local scale = 1.0
local jnhOrbWidth = 279 * scale
local jnhOrbHeight = 214 * scale
---------------------------------------------------------------------------------

-- Frame Configuration Options --------------------------------------------------
local jnhOrb = WT.UnitFrame:Template("jnhOrb")
jnhOrb.Configuration.Name = "Health+Mana+lvl Orb Unit Frame"
jnhOrb.Configuration.RaidSuitable = false
jnhOrb.Configuration.UnitSuitable = true
jnhOrb.Configuration.FrameType = "Frame"
jnhOrb.Configuration.Width = jnhOrbWidth
jnhOrb.Configuration.Height = jnhOrbHeight
jnhOrb.Configuration.Resizable = { jnhOrbWidth / 4, jnhOrbHeight / 4, jnhOrbWidth * 2, jnhOrbHeight * 2 } 
---------------------------------------------------------------------------------


function jnhOrb:Construct(options)

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
				visibilityBinding="id", texAddon = AddonId, texFile = "img/jnhOrb_back.png"		
			}, 

			-- ORB filling BG
			{
				id="orbFILLING", type="Bar", parent="frame", layer=11, alpha=1,
				attach = 
				{ 
					{ point="CENTER", element="frame", targetPoint="CENTER", offsetX=44, offsetY=1 } 
				}, visibilityBinding="id", binding="healthPercent", growthDirection="up",
				media="jnhOrb_RED", 
				height=142, width=140,		
			},
			
			-- ORB ring on top
			{
				id="orbRING", type="Image", parent="frame", layer=12, alpha=1,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" } 
				}, 				
				visibilityBinding="id", texAddon = AddonId, texFile = "img/jnhOrb_ring.png"		
			},
			
			-- HP (%)
			{
				id="healthPERCENT", type="Label", parent="frame", layer=13,
				attach = 
				{ 
					{ point="CENTER", element="orbFILLING", targetPoint="CENTER", offsetX=0, offsetY=-5 },
				}, visibilityBinding="id", text="{healthPercent}%",fontSize=36,	outline=true
			}, 
			
			-- HP (num)
			{
				id="healthNUM", type="Label", parent="frame", layer=14,
				attach = 
				{ 
					{ point="TOPCENTER", element="healthPERCENT", targetPoint="CENTER", offsetX=0, offsetY=15 },
				}, visibilityBinding="id", text="{health}",fontSize=16,	outline=true
			},
			
	-- MP ORB =====================================================================================
			-- ORB back BG
			{
				id="orbBACK2", type="Image", parent="frame", layer=5, alpha=1,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" } 
				}, 				
				visibilityBinding="resource", texAddon = AddonId, texFile = "img/jnhOrb2_back.png"		
			}, 
			
			-- ORB filling BG
			{
				id="orbFILLING2", type="Bar", parent="frame", layer=6, alpha=1,
				attach = 
				{ 
					{ point="CENTER", element="frame", targetPoint="CENTER", offsetX=-68, offsetY=35 } 
				}, visibilityBinding="resource", binding="resourcePercent", growthDirection="up",
				media="jnhOrb2_BLEU", 
				height=106, width=105,		
			},
			
			-- ORB ring on top
			{
				id="orbRING2", type="Image", parent="frame", layer=7, alpha=1,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" } 
				}, 				
				visibilityBinding="resource", texAddon = AddonId, texFile = "img/jnhOrb2_ring.png"		
			},
			
			-- MP (%)
			{
				id="manaPERCENT", type="Label", parent="frame", layer=8,
				attach = 
				{ 
					{ point="CENTER", element="orbFILLING2", targetPoint="CENTER", offsetX=0, offsetY=-2 },
				}, visibilityBinding="id", text="{resourcePercent}%",fontSize=26,	outline=true
			}, 
			
			-- MP (num)
			{
				id="manaNUM", type="Label", parent="frame", layer=9,
				attach = 
				{ 
					{ point="TOPCENTER", element="manaPERCENT", targetPoint="CENTER", offsetX=0, offsetY=8 },
				}, visibilityBinding="id", text="{resource}",fontSize=16,	outline=true
			},
	
	-- LVL + NAME =====================================================================================
			{
				id="TxtName", type="Label", parent="frame", layer=20,
				attach = 
				{ 
					{ point="TOPCENTER", element="orbBACK", targetPoint="BOTTOMCENTER", offsetX=30, offsetY=-20 },
				}, visibilityBinding="id", text="{nameShort} - {level}",fontSize=20, outline=true
			},
		}
	}
	
	WT.UnitFrame.EnableResizableTemplate(self, jnhOrbWidth, jnhOrbHeight, template.elements)
	
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
