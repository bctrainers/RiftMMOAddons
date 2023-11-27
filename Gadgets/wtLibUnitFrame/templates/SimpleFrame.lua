local toc, data = ...
local AddonId = toc.identifier

-- Local config options ---------------------------------------------------------
local simpleFrameWidth = 140
local simpleFrameTopBarHeight = 30
local simpleFrameBottomBarHeight = 16
local simpleFrameMargin = 2
local simpleFrameHeight = simpleFrameTopBarHeight + simpleFrameBottomBarHeight 
---------------------------------------------------------------------------------

-- Frame Configuration Options --------------------------------------------------
local SimpleFrame = WT.UnitFrame:Template("SimpleFrame")
SimpleFrame.Configuration.Name = "Simple Unit Frame"
SimpleFrame.Configuration.RaidSuitable = true
SimpleFrame.Configuration.UnitSuitable = true
SimpleFrame.Configuration.FrameType = "Frame"
SimpleFrame.Configuration.Width = simpleFrameWidth + 2
SimpleFrame.Configuration.Height = simpleFrameHeight + 2
SimpleFrame.Configuration.Resizable = { simpleFrameWidth + 2, simpleFrameHeight + 2, 300, 100 }
---------------------------------------------------------------------------------

-- Override the buff filter to hide some buffs ----------------------------------
local buffPriorities = 
{
	["Track Wood"] = 0,
	["Track Ore"] = 0,
	["Track Plants"] = 0,
	["Rested"] = 0,
	["Prismatic Glory"] = 0,
	["Looking for Group Cooldown"] = 0,
}
function SimpleFrame:GetBuffPriority(buff)
	if not buff then return 2 end
	return buffPriorities[buff.name] or 2
end
---------------------------------------------------------------------------------

function SimpleFrame:Construct(options)

	local template =
	{
		elements = 
		{
			{
				-- Generic Element Configuration
				id="frameBackdrop", type="Frame", parent="frame", layer=0,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" } 
				}, 				
				visibilityBinding="id",
				-- Type Specific Element Configuration
				texAddon = AddonId, texFile = "img/wtMiniFrame_bg.png", alpha=0.8,
				color={r=0,g=0,b=0,a=0.6}, colorBinding="aggroColor",
			}, 
			{
				-- Generic Element Configuration
				id="frameBlocked", type="Frame", parent="frameBackdrop", layer=15, visibilityBinding="blocked",
				color={r=0,g=0,b=0},alpha=0.6,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=1, offsetY=1 },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-1, offsetY=-1 } 
				},
			}, 
			{
				-- Generic Element Configuration
				id="barResource", type="Bar", parent="frameBackdrop", layer=10,
				attach = {
					{ point="BOTTOMLEFT", element="frame", targetPoint="BOTTOMLEFT", offsetX=1, offsetY=-1 },
					{ point="RIGHT", element="frame", targetPoint="RIGHT", offsetX=-1 },
				},
				-- visibilityBinding="id",
				-- Type Specific Element Configuration
				binding="resourcePercent", height=simpleFrameBottomBarHeight, colorBinding="resourceColor",
				texAddon=AddonId, texFile="img/Diagonal.png",
				backgroundColor={r=0, g=0, b=0, a=1}
			},
			{
				-- Generic Element Configuration
				id="barHealth", type="Bar", parent="frameBackdrop", layer=10,
				attach = {
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=1, offsetY=1 },
					{ point="BOTTOMRIGHT", element="barResource", targetPoint="TOPRIGHT" },
				},
				-- visibilityBinding="id",
				growthDirection="right",
				-- Type Specific Element Configuration
				binding="healthPercent", color={r=0,g=0.7,b=0,a=1}, 
				texAddon=AddonId, texFile="img/Diagonal.png", 
				backgroundColor={r=0, g=0, b=0, a=1}
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
				texAddon="Rift", texFile="raid_healthbar_red.png.dds",
				color={r=0.5, g=0, b=0, a=0.8},
			},	
			{
				id="barAbsorb", type="Bar", parent="frameBackdrop", layer=11,
				attach = {
					{ point="BOTTOMLEFT", element="barHealth", targetPoint="BOTTOMLEFT", offsetX=0, offsetY=0 },
					{ point="TOPRIGHT", element="barHealth", targetPoint="BOTTOMRIGHT", offsetX=0, offsetY=-4 },
				},
				growthDirection="right",
				binding="absorbPercent", color={r=0,g=1,b=1,a=1},
				media="wtBantoBar", 
				backgroundColor={r=0, g=0, b=0, a=0},
			},
			{
				-- Generic Element Configuration
				id="labelHealthR", type="Label", parent="barHealth", layer=20,
				attach = {{ point="CENTERRIGHT", element="barHealth", targetPoint="CENTERRIGHT", offsetX=-2, offsetY=0 }},
				visibilityBinding="health",
				-- Type Specific Element Configuration
				text="{health}", default="", fontSize=12
			},
			{
				-- Generic Element Configuration
				id="imgRank", type="ImageSet", parent="frame", layer=50, 
				--attach = {{ point="CENTER", element="frameBackdrop", targetPoint="TOPLEFT", offsetX=2, offsetY=2 }}, visibilityBinding="rank",
				--attach = {{ point="CENTER", element="frameBackdrop", targetPoint="TOPCENTER", offsetX=0, offsetY=2 }}, visibilityBinding="rank",
				attach = {{ point="CENTER", element="frameBackdrop", targetPoint="TOPRIGHT", offsetX=-2, offsetY=2 }}, visibilityBinding="rank",
				-- Type Specific Element Configuration
				texAddon=AddonId, texFile="img/RankPips.png", nameBinding="rank", cols=3, rows=3, 
				names ={ 
					["neutralnormal"] = 0, ["neutralgroup"] = 1, ["neutralraid"] = 2,
					["hostilenormal"] = 3, ["hostilegroup"] = 4, ["hostileraid"] = 5,
					["friendlynormal"] = 6, ["friendlygroup"] = 7, ["friendlyraid"] = 8,
					 }, defaultIndex = "hide"
			},
			{
				id="imgRole", type="ImageSet", parent="frameBackdrop", layer=20,
				attach = {{ point="CENTERLEFT", element="barHealth", targetPoint="CENTERLEFT", offsetX=2, offsetY=0 }},
				-- Type Specific Element Configuration
				texAddon=AddonId, texFile="img/Roles12.png", nameBinding="role", cols=1, rows=5, 
				names = { ["tank"] = 0, ["heal"] = 1, ["dps"] = 2, ["support"] = 3 }, defaultIndex = "hide"
			},
			{
				-- Generic Element Configuration
				id="labelName", type="Label", parent="frameBackdrop", layer=20,
				attach = {{ point="CENTERLEFT", element="imgRole", targetPoint="CENTERRIGHT", offsetX=2, offsetY=0 }},
				visibilityBinding="name",
				-- Type Specific Element Configuration
				text="{nameShort}", default="", fontSize=12
			},
			{
				-- Generic Element Configuration
				id="labelresource", type="Label", parent="barResource", layer=20,
				attach = {{ point="CENTERLEFT", element="barResource", targetPoint="CENTERLEFT" }},
				visibilityBinding="resource",
				-- Type Specific Element Configuration
				text=" {resource}/{resourceMax}", default="", fontSize=10
			},
			{
				-- Generic Element Configuration
				id="labelresourceR", type="Label", parent="barResource", layer=20,
				attach = {{ point="CENTERRIGHT", element="barResource", targetPoint="CENTERRIGHT" }},
				visibilityBinding="resource",
				-- Type Specific Element Configuration
				text="{resourcePercent}%", default="", fontSize=10
			},		
			{
		    id="imgMark", type="MediaSet", parent="frameBackdrop", layer=30,
		    attach = {{ point="CENTER", element="frameBackdrop", targetPoint="CENTER", offsetX=15, offsetY=0 }},
		    width = 24, height = 24,
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
			    visibilityBinding="mark",alpha=1.0,
			},			
			{
				id="imgRare", type="Image", parent="frameBackdrop", layer=35,
				attach = {{ point="CENTER", element="frameBackdrop", targetPoint="CENTER" }},
				texAddon="Rift", texFile="ControlPoint_Diamond_Grey.png.dds",
				visibilityBinding="guaranteedLoot",
				width=32, height=32,
			},
			
			{
				id="buffPanelDebuffs", type="BuffPanel", parent="frameBackdrop", layer=30,
				attach = {{ point="BOTTOMRIGHT", element="frameBackdrop", targetPoint="BOTTOMRIGHT", offsetX=-2, offsetY=-2 }},
				rows=2, cols=4, iconSize=18, iconSpacingHorizontal=1, iconSpacingVertical=1, borderThickness=1, 
				acceptLowPriorityBuffs=false, acceptMediumPriorityBuffs=false, acceptHighPriorityBuffs=false, acceptCriticalPriorityBuffs=false,
				acceptLowPriorityDebuffs=true, acceptMediumPriorityDebuffs=true, acceptHighPriorityDebuffs=true, acceptCriticalPriorityDebuffs=true,
				growthDirection = "left_up",
				sweepOverlay=false,
			},
			
		}
	}
	
	for idx,element in ipairs(template.elements) do
		local showElement = true
		if not options.showAbsorb and element.id == "barAbsorb" then showElement = false end
		if options.excludeBuffs and element.type=="BuffPanel" then showElement = false end
		if showElement then
			self:CreateElement(element)
		end 
	end
	
	if options.showBackground then
		self:SetBackgroundColor(0,0,0,0.2)
	end
	
	
	self:SetSecureMode("restricted")
	self:SetMouseoverUnit(self.UnitSpec)
	self:EventMacroSet(Event.UI.Input.Mouse.Left.Click, "target @" .. self.UnitSpec)
	self:EventAttach(Event.UI.Input.Mouse.Right.Click, function(self, h)
		if self.UnitId then Command.Unit.Menu(self.UnitId) end
	end, "Event.UI.Input.Mouse.Right.Click")

end
