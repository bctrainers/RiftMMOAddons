local toc, data = ...
local AddonId = toc.identifier

-- Frame Configuration Options --------------------------------------------------
local LifeismysteryHPframe = WT.UnitFrame:Template("LifeismysteryHPframe")
LifeismysteryHPframe.Configuration.Name = "Lifeismystery HP frame"
LifeismysteryHPframe.Configuration.RaidSuitable = false
LifeismysteryHPframe.Configuration.UnitSuitable = true
LifeismysteryHPframe.Configuration.FrameType = "Frame"
LifeismysteryHPframe.Configuration.Width = 250
LifeismysteryHPframe.Configuration.Height = 20
LifeismysteryHPframe.Configuration.Resizable = { 10, 10, 500, 100 }
LifeismysteryHPframe.Configuration.SupportsOwnBuffsPanel = false
LifeismysteryHPframe.Configuration.SupportsOwnDebuffsPanel = false
LifeismysteryHPframe.Configuration.SupportsExcludeBuffsPanel = false
LifeismysteryHPframe.Configuration.SupportsExcludeCastsPanel = false
LifeismysteryHPframe.Configuration.SupportsShowRadius = false
LifeismysteryHPframe.Configuration.SupportsShowCombo = false
LifeismysteryHPframe.Configuration.SupportsShowRankIconPanel = false

--------------------------------------------------------------
function LifeismysteryHPframe:Construct(options)
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
			{
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
			},	
			{
				id="barHealth", type="BarHealth", parent="frameBackdrop", layer=10,
				attach = {
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=2, offsetY=2 },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-2, offsetY=-2 },
				},
				growthDirection="left",
				binding="healthPercent",
				media="shadow", 
				backgroundColorUnit={r=0.07, g=0.07, b=0.07, a=0.85},
                backgroundColorBinding="backgroundColorUnit",							
				UnitHealthColor2={r=0.5,g=0,b=0, a=0.8},
				colorBinding="UnitHealthColor2", 	
			},
			{
				id="healthCap", type="HealthCap", parent="barHealth", layer=15,
				attach = {
					{ point="TOPLEFT", element="barHealth", targetPoint="TOPLEFT" },
					{ point="BOTTOMRIGHT", element="barHealth", targetPoint="BOTTOMRIGHT" },
				},
				growthDirection="left",
				visibilityBinding="healthCap",
				binding="healthCapPercent",
				color={r=0.5, g=0, b=0, a=0.8},
				media="wtGlaze",
			},
			{
				id="barAbsorb", type="BarWithBorder", parent="frameBackdrop", layer=11,
				attach = {
					{ point="BOTTOMLEFT", element="barHealth", targetPoint="BOTTOMLEFT", offsetX=1, offsetY=-3},
					{ point="TOPRIGHT", element="barHealth", targetPoint="BOTTOMRIGHT", offsetX=0, offsetY=-2 },
				},
				growthDirection="right",
				binding="absorbPercent", color={r=0.1,g=0.79,b=0.79,a=1.0},
				backgroundColor={r=0, g=0, b=0, a=0},
				media="Texture 69", 
				fullBorder=true,
				BarWithBorderColor={r=0,g=1,b=1,a=1},
			},
			--[[{
				id="labelhealth", type="Label", parent="frameBackdrop", layer=20,
				attach = {{ point="CENTERRIGHT", element="frame", targetPoint="CENTERRIGHT", offsetX=0, offsetY=0 }},
				visibilityBinding="health",
				text=" {health} | {healthMax}", default="", fontSize=12, outline=true,
			},
		]]
			{
				id="labelhealthPercent", type="Label", parent="frameBackdrop", layer=20, alpha=0.8,
				attach = {{ point="BOTTOMRIGHT", element="frame", targetPoint="TOPRIGHT", offsetX=5, offsetY=5 }}, 
				visibilityBinding="health",
				text="{healthPercent}%", default="", fontSize=18, outline=true, font = "Enigma",
			},					
			{
				id="labelName", type="Label", parent="frame", layer=20,
				attach = {{ point="BOTTOMLEFT", element="frame", targetPoint="TOPLEFT", offsetX=5, offsetY=5 }}, 
				visibilityBinding="name",
				text="{nameShort}", default="", outline=true, fontSize=16, font = "Enigma",
				colorBinding="NameColor",
			},
			--[[{
				id="labelStatus", type="Label", parent="frame", layer=20,
				attach = {{ point="CENTERLEFT", element="barHealth", targetPoint="CENTERRIGHT", offsetX=0, offsetY=0 }},
				visibilityBinding="UnitStatus",
				color={r = 0.38, g = 0.81, b = 1.0, a = 1.0},
				text="{UnitStatus}", default="", fontSize=14, outline = true,
			},]]
			{
			    id="imgMark", type="MediaSet", parent="frameBackdrop", layer=30,
			    attach = {{ point="TOPCENTER", element="frame", targetPoint="TOPCENTER", offsetX=0, offsetY=0 }},
			    width = 20, height = 20,
			    nameBinding="mark",
			    names = 
			    {
			        ["1"] = "riftMark01",
			        ["2"] = "riftMark02",
			        ["3"] = "riftMark03",
			        ["4"] = "riftMark04",
			        ["5"] = "riftMark05",
			        ["6"] = "riftMark06",
			        ["7"] = "riftMark07",
			        ["8"] = "riftMark08",
			        ["9"] = "riftMark09",
			        ["10"] = "riftMark10",
			        ["11"] = "riftMark11",
			        ["12"] = "riftMark12",
			        ["13"] = "riftMark13",
			        ["14"] = "riftMark14",
			        ["15"] = "riftMark15",
			        ["16"] = "riftMark16",
			        ["17"] = "riftMark17",
			        ["18"] = "riftMark18",
			        ["19"] = "riftMark19",
			        ["20"] = "riftMark20",
			        ["21"] = "riftMark21",
			        ["22"] = "riftMark22",
			        ["23"] = "riftMark23",
			        ["24"] = "riftMark24",
			        ["25"] = "riftMark25",
			        ["26"] = "riftMark26",
			        ["27"] = "riftMark27",
					["28"] = "riftMark28",
			        ["29"] = "riftMark29",
			        ["30"] = "riftMark30",
			    },
			    visibilityBinding="mark",alpha=0.8,
			},
			{
			id="imgInCombat", type="Image", parent="frame", layer=55,
			attach = {{ point="CENTER", element="frameBackdrop", targetPoint="TOPLEFT", offsetX=0, offsetY=0 }}, visibilityBinding="combat",
			texAddon=AddonId, 
			texFile="img/InCombat32.png",
			width=10, height=10,
			},
			
		}
	}
	
	for idx,element in ipairs(template.elements) do
	    local showElement = true
		if not options.showAbsorb and element.id == "barAbsorb" then showElement = false end
		if element.semantic == "HoTPanel" and not options.showHoTPanel then showElement = false	end
		if options.excludeCasts and ((element.id == "barCast") or (element.id == "labelCast") or (element.id == "labelTime")) then showElement = false end
		if not options.showCombo and element.id == "labelCombo" then showElement = false end
		if not options.showRankIcon and element.id == "imgRank" then showElement = false end
		if options.shortname == true and element.id == "labelName" then 
			element.text = "{nameShort}"
		elseif	options.shortname == false and element.id == "labelName" then 	
			element.text = "{name}"
		end
		if not options.showname == true and element.id == "labelName" then showElement = false end
		if not options.showRadius and element.id == "labelRadius" then showElement = false end	
		if showElement then
			self:CreateElement(element)
		end
	end

	self:EventAttach(
		Event.UI.Layout.Size,
		function(el)
			local newWidth = self:GetWidth()
			local newHeight = self:GetHeight()
			local fracWidth = newWidth / LifeismysteryHPframe.Configuration.Width
			local fracHeight = newHeight / LifeismysteryHPframe.Configuration.Height
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