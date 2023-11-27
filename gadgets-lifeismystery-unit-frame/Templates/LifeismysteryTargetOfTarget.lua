local toc, data = ...
local AddonId = toc.identifier

local LifeismysteryTargetOfTargetMargin = 2
-- Frame Configuration Options --------------------------------------------------
local LifeismysteryTargetOfTarget = WT.UnitFrame:Template("LifeismysteryTargetOfTarget")
LifeismysteryTargetOfTarget.Configuration.Name = "Lifeismystery Target Of Target"
LifeismysteryTargetOfTarget.Configuration.UnitSuitable = true
LifeismysteryTargetOfTarget.Configuration.FrameType = "Frame"
LifeismysteryTargetOfTarget.Configuration.Width = 250
LifeismysteryTargetOfTarget.Configuration.Height = 40
LifeismysteryTargetOfTarget.Configuration.Resizable = { 10, 10, 500, 100 }
LifeismysteryTargetOfTarget.Configuration.SupportsOwnBuffsPanel = false
LifeismysteryTargetOfTarget.Configuration.SupportsOwnDebuffsPanel = false
LifeismysteryTargetOfTarget.Configuration.SupportsExcludeBuffsPanel = false
LifeismysteryTargetOfTarget.Configuration.SupportsExcludeCastsPanel = false
LifeismysteryTargetOfTarget.Configuration.SupportsShowRadius = false
LifeismysteryTargetOfTarget.Configuration.SupportsShowCombo = false
LifeismysteryTargetOfTarget.Configuration.SupportsShowRankIconPanel = false
--------------------------------------------------------------
function LifeismysteryTargetOfTarget:Construct(options)
	local template =
	{
		elements = 
		{
			{
				-- Generic Element Configuration
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
				-- Generic Element Configuration
				id="border", type="BarHealth", parent="frameBackdrop", layer=10, alpha=1,
				attach = {
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=2, offsetY=2 },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-2, offsetY=-2 },
				},
				binding="width",
				backgroundColor={r=0, g=0, b=0, a=0},				
				Color={r=0,g=0,b=0, a=0},
				border=true, BorderColorBinding="BorderColorUnit", BorderColorUnit = {r=0,g=0,b=0,a=1},
			},	
			{
				-- Generic Element Configuration
				id="barHealth", type="BarHealth", parent="frameBackdrop", layer=10,
				attach = {
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=2, offsetY=2 },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-2, offsetY=-2 },
				},
				growthDirection="left",
				binding="healthPercent",
				backgroundColor={r=0.07, g=0.07, b=0.07, a=0.9},						
				UnitHealthColor3={r=0.5,g=0,b=0, a=0.8},
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
				-- Generic Element Configuration
				id="labelName", type="Label", parent="frame", layer=20,
				attach = {{ point="CENTER", element="border", targetPoint="CENTER", offsetX=0, offsetY=0 }},
				visibilityBinding="name",
				text="{nameShort}", default="", outline=true, fontSize=12,
				colorBinding="NameColor",
			},	
		}
	}
	
	for idx,element in ipairs(template.elements) do
		if not options.showAbsorb and element.id == "barAbsorb" then 
			-- showElement = false
		elseif element.semantic == "HoTTracker" and not options.showHoTTrackers  then
			-- showElement = false
		elseif element.semantic == "HoTPanel" and not options.showHoTPanel then
			-- showElement = false	
		else 
			self:CreateElement(element)
		end
	end

	self:EventAttach(
		Event.UI.Layout.Size,
		function(el)
			local newWidth = self:GetWidth()
			local newHeight = self:GetHeight()
			local fracWidth = newWidth / LifeismysteryTargetOfTarget.Configuration.Width
			local fracHeight = newHeight / LifeismysteryTargetOfTarget.Configuration.Height
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

WT.Unit.CreateVirtualProperty("UnitHealthColor3", { "id"},
	function(unit)
		if unit.id then
			return { r=0.5, g=0, b=0, a=0.8 }
		else
			return {r=0,g=0,b=0, a=0}
		end
	end)
	
