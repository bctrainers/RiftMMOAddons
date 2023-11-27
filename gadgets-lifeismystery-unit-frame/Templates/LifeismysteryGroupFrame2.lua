local toc, data = ...
local AddonId = toc.identifier

-- Frame Configuration Options --------------------------------------------------
local LifeismysteryGroupFrame2 = WT.UnitFrame:Template("LifeismysteryGroupFrame2")
LifeismysteryGroupFrame2.Configuration.Name = "Lifeismystery Group Frame2(big resource bar)"
LifeismysteryGroupFrame2.Configuration.RaidSuitable = false
LifeismysteryGroupFrame2.Configuration.UnitSuitable = false
LifeismysteryGroupFrame2.Configuration.FrameType = "Frame"
LifeismysteryGroupFrame2.Configuration.Width = 200
LifeismysteryGroupFrame2.Configuration.Height = 45
LifeismysteryGroupFrame2.Configuration.Resizable = { 45, 40, 700, 100 }

--------------------------------------------------------------
function LifeismysteryGroupFrame2:Construct(options)
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
				border=true, BorderColorBinding="BorderColor", BorderColor = {r=0,g=0,b=0,a=1},
				borderTextureTarget=true, BorderTextureTargetVisibleBinding="BorderTextureTargetVisible", BorderTextureTargetVisible=true,
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
				GroupHealthColor2={r=0.5,g=0,b=0, a=0.8},
				colorBinding="GroupHealthColor2", 
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
				id="barResource", type="BarWithBorder", parent="frameBackdrop", layer=10,
				attach = {
					{ point="BOTTOMLEFT", element="frame", targetPoint="BOTTOMLEFT", offsetX=2, offsetY=-2 },
					{ point="TOPRIGHT", element="barHealth", targetPoint="BOTTOMRIGHT", offsetX=0, offsetY=0 },
				},
				binding="resourcePercent", colorBinding="resourceColor",
				media="Texture 13",  
				backgroundColor={r=0.07, g=0.07, b=0.07, a=0.85},
			},
			{
				id="barAbsorb", type="BarWithBorder", parent="frameBackdrop", layer=11,
				attach = {
					{ point="BOTTOMLEFT", element="barResource", targetPoint="BOTTOMLEFT", offsetX=1, offsetY=-21},
					{ point="TOPRIGHT", element="barResource", targetPoint="BOTTOMRIGHT", offsetX=0, offsetY=-24 },
				},
				visibilityBinding="absorbPercent",
				growthDirection="right",
				binding="absorbPercent", color={r=0.1,g=0.79,b=0.79,a=1.0},
				backgroundColor={r=0, g=0, b=0, a=0},
				media="Texture 69", 
				fullBorder=true,
				BarWithBorderColor={r=0,g=1,b=1,a=1},
			},
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
				id="labellevel", type="Label", parent="frame", layer=20,
				attach = {{ point="CENTERLEFT", element="imgPVP", targetPoint="CENTERRIGHT", offsetX=0, offsetY=0  }},
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
				id="labelStatus", type="Label", parent="frame", layer=20,
				attach = {{ point="CENTERLEFT", element="labelName", targetPoint="CENTERRIGHT", offsetX=0, offsetY=0 }},
				visibilityBinding="UnitStatus",
				color={r = 0.38, g = 0.81, b = 1.0, a = 1.0},
				text="{UnitStatus}", default="", fontSize=14, outline = true,
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
			{
				id="buffPanelDebuffs", type="BuffPanel", semantic="DebuffPanel", parent="frameBackdrop", layer=30,
				attach = {{ point="BOTTOMRIGHT", element="barHealth", targetPoint="BOTTOMRIGHT", offsetX=-1, offsetY=0 }},
				rows=1, cols=6, iconSize=16, iconSpacing=1, borderThickness=1,
				auraType="debuff", 
				growthDirection = "left_up",
				--timer = true, timerSize = 14, outline=true, 
				color={r=1,g=1,b=0,a=1},
				stack = true, stackSize = 15, outline=true,
			},
			{
				id="buffPanelHoTs", type="BuffPanel", semantic="HoTPanel", parent="frameBackdrop", layer=30,
				attach = {{ point="TOPRIGHT", element="frameBackdrop", targetPoint="TOPRIGHT", offsetX=-1, offsetY=1 }},
				rows=1, cols=6, iconSize=16, iconSpacing=0, borderThickness=1,
				auraType="hot",selfCast=true, 
				timer = true, timerSize = 11, outline=true, color={r=1,g=1,b=0,a=1}, 
				stack = true, stackSize = 12, outline=true,
				growthDirection = "left_up",
			},
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
		if showElement then
			self:CreateElement(element)
		end
	end

	self:EventAttach(
		Event.UI.Layout.Size,
		function(el)
			local newWidth = self:GetWidth()
			local newHeight = self:GetHeight()
			local fracWidth = newWidth / LifeismysteryGroupFrame2.Configuration.Width
			local fracHeight = newHeight / LifeismysteryGroupFrame2.Configuration.Height
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



WT.Unit.CreateVirtualProperty("GroupHealthColor2", { "id", "offline"},
	function(unit)
		if unit.offline then
			return {r=0.07,g=0.07,b=0.09, a=0.85}
		elseif unit.id then
			return { r=0.5, g=0, b=0, a=0.8 }
		else	
			return {r=0,g=0,b=0, a=0}
		end
	end)