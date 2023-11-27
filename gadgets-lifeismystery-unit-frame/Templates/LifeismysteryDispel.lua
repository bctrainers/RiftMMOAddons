local toc, data = ...
local AddonId = toc.identifier

-- Frame Configuration Options --------------------------------------------------
local LifeismysteryDispel = WT.UnitFrame:Template("LifeismysteryDispel")
LifeismysteryDispel.Configuration.Name = "Lifeismystery Dispel Frame"
LifeismysteryDispel.Configuration.RaidSuitable = true
LifeismysteryDispel.Configuration.UnitSuitable = false
LifeismysteryDispel.Configuration.FrameType = "Frame"
LifeismysteryDispel.Configuration.Width = 30
LifeismysteryDispel.Configuration.Height = 30
LifeismysteryDispel.Configuration.Resizable = { 30, 30, 30, 30 }
LifeismysteryDispel.Configuration.SupportsOwnBuffsPanel = false
LifeismysteryDispel.Configuration.SupportsOwnDebuffsPanel = false
LifeismysteryDispel.Configuration.SupportsExcludeBuffsPanel = false
LifeismysteryDispel.Configuration.SupportsExcludeCastsPanel = false
LifeismysteryDispel.Configuration.SupportsShowRadius = false
LifeismysteryDispel.Configuration.SupportsShowCombo = false
LifeismysteryDispel.Configuration.SupportsShowRankIconPanel = false
--------------------------------------------------------------
function LifeismysteryDispel:Construct(options)
	local template =
	{
		elements = 
		{
			{
				id="frameBackdrop", type="Frame", parent="frame", layer=0, --alpha=1,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=1, offsetY=-1, },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-1, offsetY=1, } 
				},            				
				visibilityBinding="id", 
				color={r=0,g=0,b=0,a=0},
				FrameAlpha = 1,
				FrameAlphaBinding="FrameAlpha",
			}, 
			{
				id="barHealth", type="BarHealth", parent="frameBackdrop", layer=10,
				attach = {
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=2, offsetY=2 },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-2, offsetY=-2 },
				},
				binding="width",
				backgroundColorRaid={r=0.07, g=0.07, b=0.07, a=0.9},
                backgroundColorBinding="backgroundColorRaid",						
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
			},				
			
		}
	}
	
	for idx,element in ipairs(template.elements) do
			self:CreateElement(element)
	end

	self:EventAttach(
		Event.UI.Layout.Size,
		function(el)
			local newWidth = self:GetWidth()
			local newHeight = self:GetHeight()
			local fracWidth = newWidth / LifeismysteryDispel.Configuration.Width
			local fracHeight = newHeight / LifeismysteryDispel.Configuration.Height
			local fracMin = math.min(fracWidth, fracHeight)
			local fracMax = math.max(fracWidth, fracHeight)
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
	
	
WT.Unit.CreateVirtualProperty("raidHealthColor3", { "id"},
	function(unit)
		if unit.id then
			return { r=0.5, g=0, b=0, a=0.8 }
		else	
			return {r=0,g=0,b=0, a=0}
		end
	end)
	
	
WT.Unit.CreateVirtualProperty("BorderColor2", { "id"},
	function(unit)
		if not unit.id then
			return { r = 0, g=0, b = 0, a=0 }
		else
			return { r = 0, g=0, b = 0, a=1 }
		end
	end)
	
	