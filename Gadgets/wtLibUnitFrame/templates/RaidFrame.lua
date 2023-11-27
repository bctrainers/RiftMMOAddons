local toc, data = ...
local AddonId = toc.identifier

-- Local config options ---------------------------------------------------------
local raidFrameWidth = 100
local raidFrameTopBarHeight = 32
local raidFrameBottomBarHeight = 5
local raidFrameMargin = 2
local raidFrameHeight = raidFrameTopBarHeight + raidFrameBottomBarHeight 
---------------------------------------------------------------------------------

-- Frame Configuration Options --------------------------------------------------
local RaidFrame = WT.UnitFrame:Template("RaidFrame")
RaidFrame.Configuration.Name = "Default Raid Frame"
RaidFrame.Configuration.RaidSuitable = true
RaidFrame.Configuration.UnitSuitable = false
RaidFrame.Configuration.FrameType = "Frame"
RaidFrame.Configuration.Width = raidFrameWidth + 2
RaidFrame.Configuration.Height = raidFrameHeight + 2
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
function RaidFrame:GetBuffPriority(buff)
	if not buff then return 2 end
	return buffPriorities[buff.name] or 2
end
---------------------------------------------------------------------------------

function RaidFrame:Construct(options)

	local template =
	{
		elements = 
		{
			{
				-- Generic Element Configuration
				id="frameBackdrop", type="Frame", parent="frame", layer=0, alpha=0.8,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" } 
				}, 				
				visibilityBinding="id",
				color={r=0,g=0,b=0,a=1}, colorBinding="aggroColor",
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
					{ point="BOTTOMLEFT", element="frame", targetPoint="BOTTOMLEFT", offsetX=2, offsetY=-2 },
					{ point="RIGHT", element="frame", targetPoint="RIGHT", offsetX=-2 },
				},
				-- visibilityBinding="id",
				-- Type Specific Element Configuration
				binding="resourcePercent", height=raidFrameBottomBarHeight, colorBinding="callingColor",
				texAddon=AddonId, texFile="img/BantoBar.png",
				backgroundColor={r=0, g=0, b=0, a=1}
			},
			{
				-- Generic Element Configuration
				id="barHealth", type="Bar", parent="frameBackdrop", layer=10,
				attach = {
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=2, offsetY=2 },
					{ point="BOTTOMRIGHT", element="barResource", targetPoint="TOPRIGHT" },
				},
				-- visibilityBinding="id",
				growthDirection="right",
				-- Type Specific Element Configuration
				binding="healthPercent", colorBinding="callingColor",
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
				id="imgRole", type="ImageSet", parent="frameBackdrop", layer=20,
				attach = {{ point={0,0}, element="barHealth", targetPoint={0,0.1}, offsetX=3, offsetY=0 }}, visibilityBinding="role",
				-- Type Specific Element Configuration
				texAddon=AddonId, texFile="img/Roles12.png", nameBinding="role", cols=1, rows=5, 
				names = { ["tank"] = 0, ["heal"] = 1, ["dps"] = 2, ["support"] = 3 }, defaultIndex = "hide"
			},
			{
				-- Generic Element Configuration
				id="labelName", type="Label", parent="frameBackdrop", layer=20,
				attach = {{ point="CENTERLEFT", element="imgRole", targetPoint="CENTERRIGHT" }},
				visibilityBinding="name",
				-- Type Specific Element Configuration
				text="{nameShort}", default="", linkedHeightElement="barHealth", linkedHeightScale=0.35,
			},
			{
				-- Generic Element Configuration
				id="labelStatus", type="Label", parent="frameBackdrop", layer=20,
				attach = {{ point="BOTTOMCENTER", element="frameBackdrop", targetPoint="BOTTOMCENTER", offsetX=0, offsetY=-4 }},
				visibilityBinding="raidStatus",
				-- Type Specific Element Configuration
				text=" {raidStatus}", default="", fontSize=12
			},
			--[[
			{
				-- Generic Element Configuration
				id="labelMark", type="Label", parent="frameBackdrop", layer=30,
				attach = {{ point="TOPRIGHT", element="frameBackdrop", targetPoint="TOPRIGHT", offsetX=-1, offsetY=2 }},
				visibilityBinding="mark",alpha=0.6,
				-- Type Specific Element Configuration
				text="{mark}", default="X", fontSize=18
			},
			--]]
			{
			    id="imgMark", type="MediaSet", parent="frameBackdrop", layer=30,
			    attach = {{ point="TOPRIGHT", element="frameBackdrop", targetPoint="TOPRIGHT", offsetX=-3, offsetY=4 }},
			    width = 16, height = 16,
			    nameBinding="mark",
			    names = 
			    {
			        ["1"] = "riftMark01_mini",
			        ["2"] = "riftMark02_mini",
			        ["3"] = "riftMark03_mini",
			        ["4"] = "riftMark04_mini",
			        ["5"] = "riftMark05_mini",
			        ["6"] = "riftMark06_mini",
			        ["7"] = "riftMark07_mini",
			        ["8"] = "riftMark08_mini",
			        ["9"] = "riftMark09_mini",
			        ["10"] = "riftMark10_mini",
			        ["11"] = "riftMark11_mini",
			        ["12"] = "riftMark12_mini",
			        ["13"] = "riftMark13_mini",
			        ["14"] = "riftMark14_mini",
			        ["15"] = "riftMark15_mini",
			        ["16"] = "riftMark16_mini",
			        ["17"] = "riftMark17_mini",
			        ["18"] = "riftMark18_mini",
			        ["19"] = "riftMark10_mini",
			        ["20"] = "riftMark10_mini",
			        ["21"] = "riftMark10_mini",
			        ["22"] = "riftMark22_mini",
			        ["23"] = "riftMark23_mini",
			        ["24"] = "riftMark24_mini",
			        ["25"] = "riftMark25_mini",
			        ["26"] = "riftMark26_mini",
			        ["27"] = "riftMark09_mini",
					["28"] = "riftMark09_mini",
			        ["29"] = "riftMark09_mini",
			        ["30"] = "riftMark30_mini",
			    },
			    visibilityBinding="mark",alpha=1.0,
			},
			{
			    id="imgMark2", type="MediaSet", parent="frameBackdrop", layer=31,
			    attach = {{ point="CENTERRIGHT", element="imgMark", targetPoint="CENTERRIGHT", offsetX=7, offsetY=0 }},
			    width = 12, height = 12,
			    nameBinding="mark",
			    names = 
			    {
			        ["19"] = "riftMark02_mini",
			        ["20"] = "riftMark03_mini",
			        ["21"] = "riftMark04_mini",
			        ["27"] = "riftMark02_mini",
					["28"] = "riftMark03_mini",
			        ["29"] = "riftMark04_mini",
			    },
			    visibilityBinding="mark",alpha=1.0,
			},
			{
				-- Generic Element Configuration
				id="imgReady", type="ImageSet", parent="frameBackdrop", layer=30,
				attach = {{ point="CENTER", element="frame", targetPoint="CENTER" }}, -- visibilityBinding="id",
				-- Type Specific Element Configuration
				texAddon=AddonId, texFile="img/wtReady.png", nameBinding="readyStatus", cols=1, rows=2, 
				names = { ["ready"] = 0, ["notready"] = 1 }, defaultIndex = "hide"
			},
			{
				-- Generic Element Configuration
				id="buffPanel02", type="BuffPanel", parent="frameBackdrop", layer=30,
				attach = {{ point="BOTTOMRIGHT", element="frameBackdrop", targetPoint="BOTTOMRIGHT", offsetX=-1, offsetY=-2 }},
				--visibilityBinding="id",
				-- Type Specific Element Configuration
				rows=1, cols=5, iconSize=16, iconSpacing=1, borderThickness=1, 
				acceptLowPriorityBuffs=false, acceptMediumPriorityBuffs=false, acceptHighPriorityBuffs=false, acceptCriticalPriorityBuffs=false,
				acceptLowPriorityDebuffs=true, acceptMediumPriorityDebuffs=true, acceptHighPriorityDebuffs=true, acceptCriticalPriorityDebuffs=true,
				growthDirection = "left_up"
			},
		}
	}

	for idx,element in ipairs(template.elements) do
		local showElement = true
		if not options.showAbsorb and element.id == "barAbsorb" then showElement = false end
		if options.growthDirection and element.id == "barHealth" then element.growthDirection = options.growthDirection	end
		if showElement then
			self:CreateElement(element)
		end
	end
	
	self:SetSecureMode("restricted")
	self:SetMouseoverUnit(self.UnitSpec)
	self:SetMouseMasking("limited")
	if options.clickToTarget then
		self:EventMacroSet(Event.UI.Input.Mouse.Left.Click, "target @" .. self.UnitSpec)
	end
	if options.contextMenu then
		self:EventAttach(Event.UI.Input.Mouse.Right.Click, function(self, h)
			if self.UnitId then Command.Unit.Menu(self.UnitId) end
		end, "Event.UI.Input.Mouse.Right.Click")
	end

end



WT.Unit.CreateVirtualProperty("raidStatus", { "offline", "afk", "dead" },
	function(unit)
		if unit.offline then
			return "OFFLINE"
		elseif unit.afk then
			return "AFK"
		elseif unit.dead then
			return "DEAD"
		else
			return ""
		end
	end)
