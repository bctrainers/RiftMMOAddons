local toc, data = ...
local AddonId = toc.identifier

-- Frame Configuration Options --------------------------------------------------
local LifeismysteryMageFrame = WT.UnitFrame:Template("LifeismysteryMageFrame")
LifeismysteryMageFrame.Configuration.Name = "Lifeismystery Mage Frame whith Charge"
LifeismysteryMageFrame.Configuration.RaidSuitable = false
LifeismysteryMageFrame.Configuration.UnitSuitable = true
LifeismysteryMageFrame.Configuration.FrameType = "Frame"
LifeismysteryMageFrame.Configuration.Width = 250
LifeismysteryMageFrame.Configuration.Height = 40
LifeismysteryMageFrame.Configuration.Resizable = { 10, 10, 500, 100 }
LifeismysteryMageFrame.Configuration.SupportsOwnBuffsPanel = false
LifeismysteryMageFrame.Configuration.SupportsOwnDebuffsPanel = false
LifeismysteryMageFrame.Configuration.SupportsExcludeBuffsPanel = false
LifeismysteryMageFrame.Configuration.SupportsExcludeCastsPanel = true
LifeismysteryMageFrame.Configuration.SupportsShowRadius = true
LifeismysteryMageFrame.Configuration.SupportsShowCombo = true
LifeismysteryMageFrame.Configuration.SupportsShowRankIconPanel = true
--------------------------------------------------------------
function LifeismysteryMageFrame:Construct(options)
	local template =
	{
		elements = 
		{
			{
				id="frameBackdrop", type="Frame", parent="frame", layer=1, alpha=1,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=0, offsetY=0, },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=0, offsetY=0, } 
				},            				
				visibilityBinding="id",
				FrameAlpha = 1,
				FrameAlphaBinding="FrameAlpha",				
			}, 
			{
				id="border", type="BarHealth", parent="frameBackdrop", layer=10, alpha=1,
				attach = {
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=2, offsetY=2 },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-2, offsetY=-2 },
				},
				binding="width",
				backgroundColor={r=0, g=0, b=0, a=0},				
				Color={r=0,g=0,b=0, a=0},
				border=true, BorderColorBinding="BorderColorMage", BorderColorMage = {r=0,g=0,b=0,a=1},
				borderTextureAggro=true, BorderTextureAggroVisibleBinding="BorderTextureAggroVisible", BorderTextureAggroVisible=true,
			},	
			{
				id="barHealth", type="BarHealth", parent="frameBackdrop", layer=10,
				attach = {
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=2, offsetY=2 },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-2, offsetY=-20 },
				},
				growthDirection="left",
				binding="healthPercent",
				media="shadow", 
				backgroundColorUnit={r=0.07, g=0.07, b=0.07, a=0.85},
                backgroundColorBinding="backgroundColorUnit",							
				UnitHealthMage={r=0.5,g=0,b=0, a=0.8},
				colorBinding="UnitHealthMage", 
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
			{
				id="barCharge", type="BarWithBorder", parent="frameBackdrop", layer=11,
				attach = {
					{ point="BOTTOMLEFT", element="frame", targetPoint="BOTTOMLEFT", offsetX=2, offsetY=21 },
					{ point="TOPRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-2, offsetY=0 },
				},
				visibilityBinding="charge",
				binding="chargePercent", color={r=0,g=0.8,b=0.8,a=0.8},
				media="Texture 90",
				backgroundColor={r=0.07, g=0.07, b=0.07, a=0.85}
			},
			{
				id="chargeLabel", type="Label", parent="frame", layer=20,
				attach = {{ point="CENTER", element="barCharge", targetPoint="CENTER", offsetX=0, offsetY=0 }},
				text="{chargePercent}", fontSize=12, outline=true,
			},
			----------------------------------------------------------------------------------
			{
				id="barCast", type="BarWithBorder", parent="frameBackdrop", layer=25,
				attach = {
					{ point="BOTTOMLEFT", element="barCharge", targetPoint="BOTTOMLEFT", offsetX=0, offsetY=22 },
					{ point="TOPRIGHT", element="barCharge", targetPoint="BOTTOMRIGHT", offsetX=0, offsetY=0 },
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
				id="labelName", type="Label", parent="frame", layer=20,
				attach = {{ point="CENTERLEFT", element="labellevel", targetPoint="CENTERRIGHT", offsetX=0, offsetY=0 }},
				visibilityBinding="name",
				text="{nameShort}", default="", outline=true, fontSize=14,
				colorBinding="NameColor",
			},
			{
				id="labelStatus", type="Label", parent="frameBackdrop", layer=20,
				attach = {{ point="BOTTOMCENTER", element="frame", targetPoint="BOTTOMCENTER", offsetX=0, offsetY=-4 }},
				visibilityBinding="UnitStatus",
				text=" {UnitStatus}", default="", fontSize=11, outline = true,
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
		if options.shortname == true and element.id == "labelName" then 
			element.text = "{nameShort}"
		elseif	options.shortname == false and element.id == "labelName" then 	
			element.text = "{name}"
		end		
		if showElement then
			self:CreateElement(element)
		end
	end

	self:EventAttach(
		Event.UI.Layout.Size,
		function(el)
			local newWidth = self:GetWidth()
			local newHeight = self:GetHeight()
			local fracWidth = newWidth / LifeismysteryMageFrame.Configuration.Width
			local fracHeight = newHeight / LifeismysteryMageFrame.Configuration.Height
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

WT.Unit.CreateVirtualProperty("UnitHealthMage", { "id"},
	function(unit)
		if unit.id then
			return { r=0.5, g=0, b=0, a=0.8 }
		else
			return {r=0,g=0,b=0, a=0}
		end
	end)	
	
WT.Unit.CreateVirtualProperty("BorderColorMage", { "id", "aggro" },
	function(unit)
		if not unit.id then
			return { r = 0, g=0, b = 0, a=0 }
		elseif unit.aggro  then
			return { r=1, g=0, b =0, a=1 }
		elseif not unit.aggro and unit.id then
			return { r = 0, g=0, b = 0, a=1 }
		end
	end)