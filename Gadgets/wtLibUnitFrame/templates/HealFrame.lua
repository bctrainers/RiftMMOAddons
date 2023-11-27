local toc, data = ...
local AddonId = toc.identifier

-- Frame Configuration Options --------------------------------------------------
local HealFrame = WT.UnitFrame:Template("Heal Frame")
HealFrame.Configuration.Name = "Heal Frame"
HealFrame.Configuration.RaidSuitable = true
HealFrame.Configuration.UnitSuitable = false
HealFrame.Configuration.FrameType = "Frame"
HealFrame.Configuration.Width = 90
HealFrame.Configuration.Height = 40
HealFrame.Configuration.Resizable = { 55, 40, 500, 70 }
HealFrame.Configuration.SupportsHoTPanel = true
-- HealFrame.Configuration.SupportsHoTTracking = true

---------------------------------------------------------------------------------

function HealFrame:Construct(options)

	local template =
	{
		elements = 
		{
			{
				-- Generic Element Configuration
				id="outerBorder", type="Frame", parent="frame", layer=0, alpha=1,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=0, offsetY=0, },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=0, offsetY=0, } 
				}, 				
				visibilityBinding="id",
				color={r=0,g=0,b=0,a=1}, colorBinding="gridBorderColor",
			}, 
			{
				-- Generic Element Configuration
				id="frameBackdrop", type="Frame", parent="frame", layer=1, alpha=1,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=1, offsetY=1, },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-1, offsetY=-1, } 
				}, 				
				visibilityBinding="id",
				color={r=0,g=0,b=0,a=1}, colorBinding="aggroColor",
			}, 
			{
				-- Generic Element Configuration
				id="frameBlocked", type="Frame", parent="frameBackdrop", layer=15, visibilityBinding="blockedOrOutOfRange",
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
					{ point="BOTTOMLEFT", element="frameBackdrop", targetPoint="BOTTOMLEFT", offsetX=2, offsetY=-2 },
					{ point="TOPRIGHT", element="frameBackdrop", targetPoint="BOTTOMRIGHT", offsetX=-2, offsetY=-4 },
				},
				-- visibilityBinding="id",
				-- Type Specific Element Configuration
				binding="resourcePercent", height=raidFrameBottomBarHeight, colorBinding="resourceColor",
				media="wtBantoBar",
				backgroundColor={r=0, g=0, b=0, a=1}
			},
			{
				-- Generic Element Configuration
				id="barHealth", type="Bar", parent="frameBackdrop", layer=10,
				attach = {
					{ point="TOPLEFT", element="frameBackdrop", targetPoint="TOPLEFT", offsetX=2, offsetY=2 },
					{ point="BOTTOMRIGHT", element="barResource", targetPoint="TOPRIGHT", offsetX=0, offsetY=0 },
				},
				growthDirection="right",
				binding="healthPercent", 
				colorBinding="raidHealthColor",
				media="wtHealbot",
				backgroundColor={r=0, g=0, b=0, a=1},
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
				id="imgRole", type="MediaSet", parent="frameBackdrop", layer=20,
				attach = {{ point="CENTER", element="barHealth", targetPoint="TOPLEFT", offsetX=2, offsetY=2 }}, 
				visibilityBinding="role",
				nameBinding="role", 
				names = { ["tank"] = "octanusTank", ["heal"] = "octanusHeal", ["dps"] = "octanusDPS", ["support"] = "octanusSupport" },
			},		
			{
				-- Generic Element Configuration
				id="labelName", type="Label", parent="frameBackdrop", layer=20,
				attach = {{ point="CENTER", element="barHealth", targetPoint="CENTER", offsetX=0, offsetY=0 }},
				visibilityBinding="name",
				text="{name}", maxLength=8, default="", fontSize=14, outline=true,
				colorBinding="callingColor",
			},
			{
				-- Generic Element Configuration
				id="labelStatus", type="Label", parent="frameBackdrop", layer=20,
				attach = {{ point="BOTTOMCENTER", element="frameBackdrop", targetPoint="BOTTOMCENTER", offsetX=0, offsetY=-4 }},
				visibilityBinding="raidStatus",
				text=" {raidStatus}", default="", fontSize=11
			},
			{
			    id="imgMark", type="MediaSet", parent="frameBackdrop", layer=30,
			    attach = {{ point="TOPRIGHT", element="frameBackdrop", targetPoint="TOPRIGHT", offsetX=-3, offsetY=4 }},
			    width = 12, height = 12,
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
				id="buffPanelDebuffs", type="BuffPanel", parent="frameBackdrop", layer=30,
				attach = {{ point="BOTTOMRIGHT", element="frameBackdrop", targetPoint="BOTTOMRIGHT", offsetX=-1, offsetY=-1 }},
				--visibilityBinding="id",
				-- Type Specific Element Configuration
				rows=1, cols=3, iconSize=16, iconSpacing=1, borderThickness=1,
				auraType="debuff", 
				rejectBuffs= options.BlackListDebuff,
				acceptBuffs = options.WhiteListDebuff,
				growthDirection = "left_up"
			},

			{
				id="buffPanelHoTs", type="BuffPanel", semantic="HoTPanel", parent="frameBackdrop", layer=30,
				attach = {{ point="TOPRIGHT", element="frameBackdrop", targetPoint="TOPRIGHT", offsetX=-1, offsetY=1 }},
				rows=1, cols=6, iconSize=14, iconSpacing=0, borderThickness=1,
				auraType="hot",selfCast=true, 
				rejectBuffs= options.BlackListHots,
				acceptBuffs = options.WhiteListHots,
				growthDirection = "left_up",
			},

		}
	}

	for idx,element in ipairs(template.elements) do
		local showElement = true
		if not options.showAbsorb and element.id == "barAbsorb" then showElement = false end
		if element.semantic == "HoTTracker" and not options.showHoTTracker then showElement = false	end
		if element.semantic == "HoTPanel" and not options.showHoTPanel then showElement = false	end
		if element.semantic == "DebuffPanel" and not options.showDebuffPanel then showElement = false	end
		if options.growthDirection and element.id == "barHealth" then element.growthDirection = options.growthDirection	end
		if showElement then
			self:CreateElement(element)
		end
	end
	
	self:EventAttach(
		Event.UI.Layout.Size,
		function(el)
			local newWidth = self:GetWidth()
			local newHeight = self:GetHeight()
			local fracWidth = newWidth / HealFrame.Configuration.Width
			local fracHeight = newHeight / HealFrame.Configuration.Height
			local fracMin = math.min(fracWidth, fracHeight)
			local fracMax = math.max(fracWidth, fracHeight)
			local labName = self.Elements.labelName
			local origFontSize = el.fontSize or 11
			local newFontSize = math.ceil(origFontSize * fracMin)
			labName:SetFontSize(newFontSize)
		end,
		"LayoutSize")
	
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

WT.Unit.CreateVirtualProperty("gridBorderColor", { "playerTarget" },
	function(unit)
		if unit.playerTarget then
			return { r=1, g=1, b=1, a=1 }
		else
			return nil
		end
	end)

WT.Unit.CreateVirtualProperty("raidHealthColor", { "id", "cleansable" },
	function(unit)
		if unit.cleansable then
			return { r=0.5, g=0, b=0.5, a=1 }
		else
			return { r=0, g=0.5, b=0, a=1 }
		end
	end)
	