local toc, data = ...
local AddonId = toc.identifier

-- Frame Configuration Options --------------------------------------------------
local LifeismysteryMiniFrame = WT.UnitFrame:Template("LifeismysteryMiniFrame")
LifeismysteryMiniFrame.Configuration.Name = "Lifeismystery Mini frame"
LifeismysteryMiniFrame.Configuration.RaidSuitable = false
LifeismysteryMiniFrame.Configuration.UnitSuitable = true
LifeismysteryMiniFrame.Configuration.FrameType = "Frame"
LifeismysteryMiniFrame.Configuration.Width = 250
LifeismysteryMiniFrame.Configuration.Height = 20
LifeismysteryMiniFrame.Configuration.Resizable = { 180, 10, 500, 30 }
LifeismysteryMiniFrame.Configuration.SupportsOwnBuffsPanel = false
LifeismysteryMiniFrame.Configuration.SupportsOwnDebuffsPanel = false
LifeismysteryMiniFrame.Configuration.SupportsExcludeBuffsPanel = false
LifeismysteryMiniFrame.Configuration.SupportsExcludeCastsPanel = false
LifeismysteryMiniFrame.Configuration.SupportsShowRadius = false
LifeismysteryMiniFrame.Configuration.SupportsShowCombo = false
LifeismysteryMiniFrame.Configuration.SupportsShowRankIconPanel = false

--------------------------------------------------------------
function LifeismysteryMiniFrame:Construct(options)

local newWidth2 = options.width or LifeismysteryMiniFrame.Configuration.Width 

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
				id="border", type="Bar", parent="frameBackdrop", layer=2, alpha=1,
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
				id="barHealth", type="BarHealth", parent="frameBackdrop", layer=1,
				attach = {
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=2, offsetY=2 },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-newWidth2/2, offsetY=-2 },
				},
				growthDirection="right",
				binding="healthPercent",
				media="shadow", 
				backgroundColorUnit={r=0.07, g=0.07, b=0.07, a=0.85},
                backgroundColorBinding="backgroundColorUnit",							
				UnitHealthColorMini={r=0.5,g=0,b=0, a=0.8},
				colorBinding="UnitHealthColorMini", 	
			},	
			{
				id="healthCap", type="HealthCap", parent="barHealth", layer=2,
				attach = {
				{ point="BOTTOMLEFT", element="barHealth", targetPoint="BOTTOMLEFT" },
				{ point="TOPRIGHT", element="barHealth", targetPoint="TOPRIGHT" },
					
				},
				growthDirection="right",
				visibilityBinding="healthCap",
				binding="healthCapPercent",
				color={r=0.5, g=0, b=0, a=0.8},
				media="wtGlaze",
				rightBorder=true,
			},
			{
				id="barResource", type="BarHealth", parent="frame", layer=1,
				attach = {
					{ point="TOPRIGHT", element="frame", targetPoint="TOPRIGHT", offsetX=-2, offsetY=2 },
					{ point="BOTTOMLEFT", element="frame", targetPoint="BOTTOMLEFT", offsetX=newWidth2/2, offsetY=-2 },
				},
				binding="resourcePercent", colorBinding="resourceColor",
				media="shadow", 
				growthDirection="left",				
				backgroundColor={r=0.07, g=0.07, b=0.07, a=0.85},
				wight = 100,
			},			
			{
				id="barAbsorb", type="BarWithBorder", parent="barHealth", layer=2,
				attach = {
					{ point="BOTTOMLEFT", element="frame", targetPoint="BOTTOMLEFT", offsetX=3, offsetY=-3},
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
				text=" {health} | {healthMax}", default="", fontSize=12, outline=true, font = "Enigma",
			},]]			
			{
				id="labelhealthPercent", type="Label", parent="frameBackdrop", layer=2, alpha=1,
				attach = {{ point="BOTTOMLEFT", element="frame", targetPoint="TOPLEFT", offsetX=5, offsetY=0 }}, 
				visibilityBinding="health",
				text="{healthPercent}", default="", fontSize=20, outline=true, font = "blank-Bold",
			},
			{
				id="labelresource", type="Label", parent="frameBackdrop", layer=1, alpha=1,
				attach = {{ point="BOTTOMRIGHT", element="frame", targetPoint="TOPRIGHT", offsetX=-5, offsetY=0 }},
				visibilityBinding="resource", --colorBinding="resourceColor",
				text="{resourcePercent}", default="", fontSize=20, outline=true, font = "blank-Bold",			},			
			{
				id="labelName", type="Label", parent="frame", layer=20,
				attach = {{ point="TOPCENTER", element="frame", targetPoint="TOPCENTER", offsetX=0, offsetY=-20 }}, 
				visibilityBinding="name",
				text="{nameShort}", default="", outline=true, fontSize=16, font = "Enigma",
				colorBinding="NameColor",
			},
			--"underscore.png.dds"
			--"line_window_break.png.dds"
			--[[{
				id="line", type="Image", parent="frame", layer=4, alpha=1,
				attach = 
				{ 
					{ point="BOTTOMCENTER", element="frame", targetPoint="BOTTOMCENTER", offsetX=0, offsetY=1 },
				}, 				
				visibilityBinding="id",
				texAddon = "Rift", texFile = "underscore.png.dds", alpha=0.75,
				backgroundColor={r=0, g=0, b=0, a=1},
				width = newWidth2, height=6,
			},]]
			{
				id="Square_1", type="Image", parent="frame", layer=2, alpha=1,
				attach = 
				{ 
					{ point="CENTERLEFT", element="frame", targetPoint="CENTERLEFT", offsetX=-42, offsetY=0 },
				}, 				
				visibilityBinding="id",
				texAddon = AddonId, texFile = "img/267.png", alpha=0.75,
				backgroundColor={r=0, g=0, b=0, a=1},
				width = 50, height=50,
			},
			{
				id="Square_2", type="Image", parent="frame", layer=2, alpha=1,
				attach = 
				{ 
					{ point="CENTERRIGHT", element="frame", targetPoint="CENTERRIGHT", offsetX=38, offsetY=0 }, 
				}, 				
				visibilityBinding="id",
				texAddon = AddonId, texFile = "img/268.png", alpha=0.75,
				backgroundColor={r=0, g=0, b=0, a=1},
				width = 50, height=50,
			},
-------------------------------------------------------------------------------------------------------------------			
			{
				id="Image1", type="Image", parent="frame", layer=1,
				attach = 
				{ 
					{ point="CENTERLEFT", element="frame", targetPoint="CENTERLEFT", offsetX=-45, offsetY=-20 },
				}, 				
				visibilityBinding="inCombat",
				texAddon = "Rift", texFile = "QuestStickies_I7D.dds",
				backgroundColor={r=0, g=0, b=0, a=0},
				width = 45, height=60,
				--Starburst_Aqua.png.dds
				--"vfx__glow_01.png.dds"
				--"questMessaging_star.png.dds"
				--"WE_VFX_CenterTwirl_yellow.png.dds"
				--"RiftTear_Flame_01.png.dds"
				--"Lightning_05.png.dds"
				--AuctionHouse_I18C.dds
				--AuctionHouse_I2E.dds
				--frame3.png.dds
				--Merchant_I222.dds
				--Minion_I214.dds + Minion_I217.dds (QuestStickies_I7D.dds QuestStickies_I80.dds QuestStickies_I83.dds)
				--Minion_I222.dds + Minion_I226.dds + Minion_I229.dds
			},
			{
				id="Image1_1", type="Image", parent="frame", layer=1,
				attach = 
				{ 
					{ point="CENTERLEFT", element="frame", targetPoint="CENTERLEFT", offsetX=-45, offsetY=-20 },
				}, 				
				visibilityBinding="inCombat",
				texAddon = "Rift", texFile = "QuestStickies_I80.dds",
				backgroundColor={r=0, g=0, b=0, a=0},
				width = 45, height=70,
			},
			{
				id="Image1_2", type="Image", parent="frame", layer=1,
				attach = 
				{ 
					{ point="CENTERLEFT", element="frame", targetPoint="CENTERLEFT", offsetX=-45, offsetY=-20 },
				}, 				
				visibilityBinding="inCombat",
				texAddon = "Rift", texFile = "QuestStickies_I83.dds",
				backgroundColor={r=0, g=0, b=0, a=0},
				width = 45, height=60,
			},
			{
				id="Image2", type="Image", parent="frame", layer=1,
				attach = 
				{ 
					{ point="CENTERRIGHT", element="frame", targetPoint="CENTERRIGHT", offsetX=40, offsetY=-20 },				}, 				
				visibilityBinding="inCombat",
				texAddon = "Rift", texFile = "QuestStickies_I7D.dds",
				backgroundColor={r=0, g=0, b=0, a=0},
				width = 45, height=70,
			},
			{
				id="Image2_1", type="Image", parent="frame", layer=1,
				attach = 
				{ 
					{ point="CENTERRIGHT", element="frame", targetPoint="CENTERRIGHT", offsetX=40, offsetY=-20 },
				}, 				
				visibilityBinding="inCombat",
				texAddon = "Rift", texFile = "QuestStickies_I80.dds",
				backgroundColor={r=0, g=0, b=0, a=0},
				width = 45, height=60,
			},
			{
				id="Image2_2", type="Image", parent="frame", layer=1,
				attach = 
				{ 
					{ point="CENTERRIGHT", element="frame", targetPoint="CENTERRIGHT", offsetX=40, offsetY=-20 },
				}, 				
				visibilityBinding="inCombat",
				texAddon = "Rift", texFile = "QuestStickies_I83.dds",
				backgroundColor={r=0, g=0, b=0, a=0},
				width = 45, height=60,
			},
			
			--[[{
				id="Image2", type="Image", parent="frame", layer=1,
				attach = 
				{ 
					{ point="CENTERRIGHT", element="frame", targetPoint="CENTERRIGHT", offsetX=100, offsetY=0 },				}, 				
				visibilityBinding="inCombat",
				texAddon = "Rift", texFile = "Minion_I222.dds",
				backgroundColor={r=0, g=0, b=0, a=0},
				width = 80, height=45,
			},
			{
				id="Image2_1", type="Image", parent="frame", layer=1,
				attach = 
				{ 
					{ point="CENTERRIGHT", element="frame", targetPoint="CENTERRIGHT", offsetX=100, offsetY=0 },
				}, 				
				visibilityBinding="inCombat",
				texAddon = "Rift", texFile = "Minion_I226.dds",
				backgroundColor={r=0, g=0, b=0, a=0},
				width = 80, height=45,
			},
			{
				id="Image2_2", type="Image", parent="frame", layer=1,
				attach = 
				{ 
					{ point="CENTERRIGHT", element="frame", targetPoint="CENTERRIGHT", offsetX=100, offsetY=0 },
				}, 				
				visibilityBinding="inCombat",
				texAddon = "Rift", texFile = "Minion_I229.dds",
				backgroundColor={r=0, g=0, b=0, a=0},
				width = 80, height=45,
			},]]
-------------------------------------------------------------------------------------------------------------------			
			--[[{
			    id="imgMark", type="MediaSet", parent="frameBackdrop", layer=30,
			    attach = {{ point="TOPCENTER", element="frame", targetPoint="TOPCENTER", offsetX=0, offsetY=-20 }},
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
			    visibilityBinding="mark",alpha=1,
			},]]
			{
			id="imgInCombat", type="Image", parent="frame", layer=55,
			attach = {{ point="CENTER", element="frameBackdrop", targetPoint="TOPLEFT", offsetX=0, offsetY=0 }}, 
			visibilityBinding="combat",
			texAddon=AddonId, 
			texFile="img/InCombat32.png",
			width=10, height=10,
			},
			
		}
	}
	
	local animations =
		{
            {
                trigger = "inCombat",
                duration = .50,
                loopCount = 0,
                onStart =
					function(elements)
						elements.Image1:SetAlpha(.3)
						elements.Image2:SetAlpha(.3)
                        end,
					onTick =
                        function(elements, elapsed, progress)
                            elements.Image1:SetAlpha((math.sin(progress * (2.0 * math.pi)) + 1.5) / 1.0)
							elements.Image2:SetAlpha((math.sin(progress * (2.0 * math.pi)) + 1.5) / 1.0)
                        end,             
					onFinish =
                        function(elements)
                            elements.Image1:SetAlpha(.5)
							elements.Image2:SetAlpha(.5)
                        end,             
            },
      }
	 local animations2 =
		{
            {
                trigger = "inCombat",
                duration = .70,
                loopCount = 0,
                onStart =
					function(elements)
						elements.Image1_1:SetAlpha(.4)
						elements.Image2_1:SetAlpha(.4)
                        end,
					onTick =
                        function(elements, elapsed, progress)
							elements.Image1_1:SetAlpha((math.sin(progress * (2.0 * math.pi)) + 1.5) / 1.0)
							elements.Image2_1:SetAlpha((math.sin(progress * (2.0 * math.pi)) + 1.5) / 1.0)
                        end,             
					onFinish =
                        function(elements)
							elements.Image1_1:SetAlpha(.6)
							elements.Image2_1:SetAlpha(.6)
                        end,             
            },
      }
	  
  	 local animations3 =
		{
            {
                trigger = "inCombat",
                duration = .90,
                loopCount = 0,
                onStart =
					function(elements)
						elements.Image1_2:SetAlpha(.5)
						elements.Image2_2:SetAlpha(.5)
                        end,
					onTick =
                        function(elements, elapsed, progress)
							elements.Image1_2:SetAlpha((math.sin(progress * (2.0 * math.pi)) + 1.5) / 1.0)
							elements.Image2_2:SetAlpha((math.sin(progress * (2.0 * math.pi)) + 1.5) / 1.0)
                        end,             
					onFinish =
                        function(elements)
							elements.Image1_2:SetAlpha(.7)
							elements.Image2_2:SetAlpha(.7)
                        end,             
            },
      }   
      if WT.UnitFrame.EnableAnimation then
            WT.UnitFrame.EnableAnimation(self, animations)
			WT.UnitFrame.EnableAnimation(self, animations2)
			WT.UnitFrame.EnableAnimation(self, animations3)
      end
	
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
			local fracWidth = newWidth / LifeismysteryMiniFrame.Configuration.Width
			local fracHeight = newHeight / LifeismysteryMiniFrame.Configuration.Height
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