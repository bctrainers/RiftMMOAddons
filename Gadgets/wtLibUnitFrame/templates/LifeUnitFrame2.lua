local toc, data = ...
local AddonId = toc.identifier

-- Frame Configuration Options --------------------------------------------------
local LifeUnitFrame2 = WT.UnitFrame:Template("LifeUnitFrame2")
LifeUnitFrame2.Configuration.Name = "Life Unit Frame2 (Green health/big resource bar)"
LifeUnitFrame2.Configuration.RaidSuitable = false
LifeUnitFrame2.Configuration.UnitSuitable = true
LifeUnitFrame2.Configuration.FrameType = "Frame"
LifeUnitFrame2.Configuration.Width = 250
LifeUnitFrame2.Configuration.Height = 40
LifeUnitFrame2.Configuration.Resizable = { 10, 10, 500, 100 }
LifeUnitFrame2.Configuration.SupportsOwnBuffsPanel = false
LifeUnitFrame2.Configuration.SupportsOwnDebuffsPanel = false
LifeUnitFrame2.Configuration.SupportsExcludeBuffsPanel = false
LifeUnitFrame2.Configuration.SupportsExcludeCastsPanel = true
LifeUnitFrame2.Configuration.SupportsShowRadius = true
LifeUnitFrame2.Configuration.SupportsShowCombo = true
LifeUnitFrame2.Configuration.SupportsShowRankIconPanel = true

--------------------------------------------------------------
function LifeUnitFrame2:Construct(options)
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
				id="barHealth", type="Bar", parent="frameBackdrop", layer=10,
				attach = {
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=2, offsetY=2 },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-2, offsetY=-20 },
				},
				growthDirection="right",
				binding="healthPercent",
				media="Texture 39", 
				HealthUnitColor={r=0.22,g=0.55,b=0.06, a=0.85},
				colorBinding="HealthUnitColor",	
				backgroundColor={r=0.07, g=0.07, b=0.07, a=0.85},
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
				id="barResource", type="BarWithBorder", parent="frameBackdrop", layer=11,
				attach = {
					{ point="BOTTOMLEFT", element="frame", targetPoint="BOTTOMLEFT", offsetX=2, offsetY=-2 },
					{ point="TOPRIGHT", element="barHealth", targetPoint="BOTTOMRIGHT", offsetX=0, offsetY=0 },
				},
				binding="resourcePercent", colorBinding="resourceColor",
				media="Texture 13", 
				backgroundColor={r=0.07, g=0.07, b=0.07, a=0.85},
			},
			{
				id="barAbsorb", type="BarWithBorder", parent="frameBackdrop", layer=12,
				attach = {
					{ point="BOTTOMLEFT", element="barResource", targetPoint="BOTTOMLEFT", offsetX=1, offsetY=-21},
					{ point="TOPRIGHT", element="barResource", targetPoint="BOTTOMRIGHT", offsetX=0, offsetY=-24 },
				},
				growthDirection="right",
				visibilityBinding="absorbPercent",
				binding="absorbPercent", color={r=0.1,g=0.79,b=0.79,a=1.0},
				backgroundColor={r=0, g=0, b=0, a=0},
				media="Texture 69", 
				fullBorder=true,
				BarWithBorderColor={r=0,g=1,b=1,a=1}, 
			},
			----------------------------------------------------------
			{
				id="barCast", type="BarWithBorder", parent="frameBackdrop", layer=25,
				attach = {
					{ point="BOTTOMLEFT", element="barResource", targetPoint="BOTTOMLEFT", offsetX=0, offsetY=22 },
					{ point="TOPRIGHT", element="barResource", targetPoint="BOTTOMRIGHT", offsetX=0, offsetY=0 },
				},
				visibilityBinding="castName",
				binding="castPercent",
				media="Texture 58",
				colorBinding="castColor",
				backgroundColor={r=0.07, g=0.07, b=0.07, a=1}
			},
			{
				id="labelCast", type="Label", parent="frameBackdrop", layer=26,
				attach = {{ point="CENTERLEFT", element="barCast", targetPoint="CENTERLEFT", offsetX=0, offsetY=0 }},
				visibilityBinding="castName",
				text="{castName}", default="", fontSize=13, outline=true,
			},
			{
				id="labelTime", type="Label", parent="frameBackdrop", layer=26,
				attach = {{ point="CENTERRIGHT", element="barCast", targetPoint="CENTERRIGHT", offsetX=0, offsetY=0 }},
				visibilityBinding="castName",
				text="{castTime}", default="", fontSize= 13, outline = true
			},
			----------------------------------------------------------------------------------
			{
				id="labelhealth", type="Label", parent="frameBackdrop", layer=20,
				attach = {{ point="CENTERLEFT", element="barResource", targetPoint="CENTERLEFT", offsetX=0, offsetY=0 }},
				visibilityBinding="health",
				text=" {health} | {healthMax}", default="", fontSize=12, outline=true,
			},
			{
				id="labelresource", type="Label", parent="frameBackdrop", layer=20, alpha=1,
				attach = {{ point="CENTERRIGHT", element="barResource", targetPoint="CENTERRIGHT", offsetX=0, offsetY=0 }},
				visibilityBinding="resource", colorBinding="resourceColor",
				text=" {resource}", default="", fontSize=12, outline=true,
			},			
			{
				id="labelhealthPercent", type="Label", parent="frameBackdrop", layer=20,
				attach = {{ point="CENTERRIGHT", element="labelresource", targetPoint="CENTERLEFT", offsetX=5, offsetY=0   }},
				visibilityBinding="health",
				text="{healthPercent}%", default="", fontSize=12, outline=true,
			},	
			{
				id="imgRole", type="MediaSet", parent="frameBackdrop", layer=20,
				attach = {{ point="BOTTOMLEFT", element="frame", targetPoint="TOPLEFT", offsetX=5, offsetY=7 }}, 
				visibilityBinding="role",
				nameBinding="role", 
				names = { ["tank"] = "iconRoleTank", ["heal"] = "iconRoleHeal", ["dps"] = "iconRoleDPS", ["support"] = "iconRoleSupport" },
				width = 12, height = 12,
				defaultIndex = "hide",
			},	
			{
				id="imgPVP", type="MediaSet", parent="frame", layer=20, width=16, height=16,
				attach = {{ point="CENTERLEFT", element="imgRole", targetPoint="CENTERRIGHT", offsetX=0, offsetY=0 }}, 
				nameBinding="pvpAlliance",
				names = 
				{
					["defiant"] = "FactionDefiant",
					["guardian"] = "FactionGuardian",
					["nightfall"] = "FactionNightfall",
					["oathsworn"] = "FactionOathsworn",
					["dominion"] = "FactionDominion",
				},
			},	
			{
				id="imgRare", type="Image", parent="frame", layer=50,
				attach = {{  point="TOPCENTER", element="frame", targetPoint="TOPCENTER", offsetX=0, offsetY=8 }},
				visibilityBinding="guaranteedLoot",
				media="RareMob",
			},			
			{
				id="labellevel", type="Label", parent="frame", layer=21,
				attach = {{ point="CENTERLEFT", element="imgPVP", targetPoint="CENTERRIGHT", offsetX=0, offsetY=0 }},
				visibilityBinding="name",
				text="{level}", default="", outline=true, fontSize=14,
				colorBinding="lvlColor",
			},
			{
				id="imgMentor", type="Image", parent="frame", layer=50, width=60, height=30,
				attach = {{  point="CENTER", element="labellevel", targetPoint="CENTER", offsetX=0, offsetY=-12 }},
				visibilityBinding="mentoring",
				media="Mentoring",
			},
			{
				id="imgBossLvl", type="MediaSet", parent="frame", layer=50, width=18, height=28,
				attach = {{  point="CENTER", element="labellevel", targetPoint="CENTER", offsetX=0, offsetY=-5 }},
				nameBinding="level",
				names = { 
						["??"] = "icon_boss", 
						}, 
				defaultIndex = "hide",
			},
			{
				id="imgRank", type="MediaSet", parent="frame", layer=19, width=50, height=50,
				attach = {{  point="CENTER", element="labellevel", targetPoint="CENTER", offsetX=0, offsetY=2 }},
				nameBinding="tier",
				names ={ 
						["group"] = "Icon_group", 
						["raid"] = "Icon_raid"
						}, 
				defaultIndex = "hide",
			},			
			{
				id="labelName", type="Label", parent="frame", layer=20,
				attach = {{ point="CENTERLEFT", element="labellevel", targetPoint="CENTERRIGHT", offsetX=0, offsetY=0 }},
				visibilityBinding="name",
				text="{nameShort}", default="", outline=true, fontSize=14,
				colorBinding="NameColor",
			},
			{
				id="labelCombo", type="Label", parent="frame", layer=20,
				attach = {{ point="BOTTOMRIGHT", element="frame", targetPoint="TOPRIGHT", offsetX=-5, offsetY=17}},
				visibilityBinding="visibilityCombo",
				text="{combo}", default="", outline=true, fontSize=25,
				colorBinding="ComboColor",
				font = "ArmWrestler",
			},
			{
				id="labelStatus", type="Label", parent="frame", layer=20,
				attach = {{ point="CENTERLEFT", element="labelName", targetPoint="CENTERRIGHT", offsetX=0, offsetY=0 }},
				visibilityBinding="UnitStatus",
				color={r = 0.38, g = 0.81, b = 1.0, a = 1.0},
				text="{UnitStatus}", default="", fontSize=14, outline = true,
			},
			{
				id="labelRadius", type="Label", parent="frameBackdrop", layer=20,
				attach = {{ point="BOTTOMLEFT", element="barHealth", targetPoint="BOTTOMLEFT", offsetX=0, offsetY=-3 }},
				visibilityBinding="Radius",
				color={r = 0.38, g = 0.81, b = 1.0, a = 1.0},
				text="HitBox:{Radius}", default="", fontSize=12, outline = true,
			},			
			{
			    id="imgMark", type="MediaSet", parent="frameBackdrop", layer=30,
			    attach = {{ point="TOPCENTER", element="frame", targetPoint="TOPCENTER", offsetX=0, offsetY=10 }},
			    width = 25, height = 25,
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
				id="imgReady", type="ImageSet", parent="frameBackdrop", layer=30,
				attach = {{ point="CENTER", element="frame", targetPoint="CENTER" }},
				texAddon=AddonId, texFile="img/wtReady.png", nameBinding="readyStatus", cols=1, rows=2, 
				names = { ["ready"] = 0, ["notready"] = 1 }, defaultIndex = "hide"
			},
			--[[{
				-- Generic Element Configuration
				id="buffPanelDebuffs", type="BuffPanel", parent="frameBackdrop", layer=30,
				attach = {{ point="TOPRIGHT", element="frameBackdrop", targetPoint="TOPRIGHT", offsetX=-1, offsetY=-37 }},
				--visibilityBinding="id",
				-- Type Specific Element Configuration
				rows=1, cols=6, iconSize=30, iconSpacing=1, borderThickness=1,
				auraType="debuff", 
				growthDirection = "left_up",
				timer = true, timerSize = 14, outline=true, 
				color={r=1,g=1,b=0,a=1},
				stack = true, stackSize = 15, outline=true,
			},
			{
				id="buffPanelHoTs", type="BuffPanel", parent="frameBackdrop", layer=30, --semantic="HoTPanel"
				attach = {{ point="BOTTOMLEFT", element="frameBackdrop", targetPoint="BOTTOMLEFT", offsetX=1, offsetY=25 }},
				rows=4, cols=7, iconSize=0, iconSpacing=0, borderThickness=1,
				auraType="buff",selfCast=false, 
				timer = true, timerSize = 11, outline=true, color={r=1,g=1,b=0,a=1}, 
				stack = true, stackSize = 12, outline=true,
				growthDirection = "right_down",
			},]]
			{
			id="imgInCombat", type="Image", parent="frame", layer=55,
			attach = {{ point="CENTER", element="frameBackdrop", targetPoint="TOPLEFT", offsetX=0, offsetY=20 }}, visibilityBinding="combat",
			texAddon=AddonId, 
			texFile="img/InCombat32.png",
			width=15, height=15,
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
			local fracWidth = newWidth / LifeUnitFrame2.Configuration.Width
			local fracHeight = newHeight / LifeUnitFrame2.Configuration.Height
			local fracMin = math.min(fracWidth, fracHeight)
			local fracMax = math.max(fracWidth, fracHeight)
			local labName = self.Elements.labelName
			labName:SetFontSize(16)
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