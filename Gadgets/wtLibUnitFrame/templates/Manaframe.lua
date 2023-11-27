local toc, data = ...
local AddonId = toc.identifier

-- Frame Configuration Options --------------------------------------------------
local Manaframe = WT.UnitFrame:Template("Manaframe")
Manaframe.Configuration.Name = "Mana frame"
Manaframe.Configuration.RaidSuitable = false
Manaframe.Configuration.UnitSuitable = true
Manaframe.Configuration.FrameType = "Frame"
Manaframe.Configuration.Width = 250
Manaframe.Configuration.Height = 20
Manaframe.Configuration.Resizable = { 10, 10, 500, 100 }
Manaframe.Configuration.SupportsOwnBuffsPanel = false
Manaframe.Configuration.SupportsOwnDebuffsPanel = false
Manaframe.Configuration.SupportsExcludeBuffsPanel = false
Manaframe.Configuration.SupportsExcludeCastsPanel = false
Manaframe.Configuration.SupportsShowRadius = false
Manaframe.Configuration.SupportsShowCombo = false
Manaframe.Configuration.SupportsShowRankIconPanel = false


--------------------------------------------------------------
function Manaframe:Construct(options)
	local template =
	{
		elements = 
		{
			{
				id="frameBackdrop", type="Frame", parent="frame", layer=1, alpha=1,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=1, offsetY=-1, },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-1, offsetY=1, } 
				},            				
				visibilityBinding="id",
				FrameAlpha = 1,
				FrameAlphaBinding="FrameAlpha",				
			}, 
		--[[	{
				id="border", type="Bar", parent="frameBackdrop", layer=10, alpha=1,
				attach = {
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=2, offsetY=2 },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-2, offsetY=-2 },
				},
				binding="borderWigth",
				backgroundColor={r=0, g=0, b=0, a=0},				
				Color={r=0,g=0,b=0, a=0},
				border=true, BorderColorBinding="BorderColorUnitFrame", BorderColorUnitFrame = {r=0,g=0,b=0,a=1},
				borderTextureAggro=true, BorderTextureAggroVisibleBinding="BorderTextureAggroVisible", BorderTextureAggroVisible=true,
			},	]]
			--[[{
				id="barHealth", type="Bar", parent="frameBackdrop", layer=10,
				attach = {
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=2, offsetY=2 },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-2, offsetY=-2 },
				},
				growthDirection="right",
				binding="healthPercent",
				media="Texture 39", 
				HealthUnitColor={r=0.22,g=0.55,b=0.06, a=0.85},
				colorBinding="HealthUnitColor",	
				backgroundColor={r=0.07, g=0.07, b=0.07, a=0.85},
			},]]
			{
				id="barResource", type="BarWithBorder", parent="frameBackdrop", layer=11,
				attach = {
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=2, offsetY=2 },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-2, offsetY=-2 },
				},
				binding="resourcePercent", colorBinding="resourceColor",
				media="Texture 13", 
				backgroundColor={r=0.07, g=0.07, b=0.07, a=0.85},
			},
			{
				id="border2", type="Bar", parent="frameBackdrop", layer=10, alpha=1,
				attach = {
					{ point="BOTTOMLEFT", element="frame", targetPoint="BOTTOMLEFT", offsetX=2, offsetY=-2 },
					{ point="TOPRIGHT", element="barResource", targetPoint="BOTTOMRIGHT", offsetX=0, offsetY=0 },
				},
				binding="borderWidth",
				backgroundColor={r=0, g=0, b=0, a=1},				
				Color={r=0,g=0,b=0, a=1},
			},
			--[[{
				id="labelhealth", type="Label", parent="frameBackdrop", layer=20,
				attach = {{ point="CENTERRIGHT", element="frame", targetPoint="CENTERRIGHT", offsetX=0, offsetY=0 }},
				visibilityBinding="health",
				text=" {health} | {healthMax}", default="", fontSize=12, outline=true,
			},
		
			{
				id="labelhealthPercent", type="Label", parent="frameBackdrop", layer=20,
				attach = {{ point="CENTERRIGHT", element="labelhealth", targetPoint="CENTERRIGHT", offsetX=0, offsetY=0   }},
				visibilityBinding="health",
				text="{healthPercent}%", default="", fontSize=12, outline=true,
			},	]]				
			
		}
	}
	
	for idx,element in ipairs(template.elements) do
	    local showElement = true
		if options.shortname == true and element.id == "labelName" then 
			element.text = "{nameShort}"
		elseif	options.shortname == false and element.id == "labelName" then 	
			element.text = "{name}"
		end
		if not options.showname == true and element.id == "labelName" then showElement = false end
		if showElement then
			self:CreateElement(element)
		end
	end

	self:EventAttach(
		Event.UI.Layout.Size,
		function(el)
			local newWidth = self:GetWidth()
			local newHeight = self:GetHeight()
			local fracWidth = newWidth / Manaframe.Configuration.Width
			local fracHeight = newHeight / Manaframe.Configuration.Height
			local fracMin = math.min(fracWidth, fracHeight)
			local fracMax = math.max(fracWidth, fracHeight)
		end,
		"LayoutSize")
	
	self:SetSecureMode("restricted")
	self:SetMouseoverUnit(self.UnitSpec)
	
	if options.clickToTarget then
		self.Event.LeftClick = "target @" .. self.UnitSpec
	end
	
	if options.contextMenu then 
		self.Event.RightClick = 
			function() 
				if self.UnitId then 
					Command.Unit.Menu(self.UnitId) 
				end 
			end 
	end
	
 end  