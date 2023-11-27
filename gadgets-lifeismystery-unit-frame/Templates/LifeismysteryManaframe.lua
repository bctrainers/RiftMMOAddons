local toc, data = ...
local AddonId = toc.identifier

-- Frame Configuration Options --------------------------------------------------
local LifeismysteryManaframe = WT.UnitFrame:Template("LifeismysteryManaframe")
LifeismysteryManaframe.Configuration.Name = "Lifeismystery Mana frame"
LifeismysteryManaframe.Configuration.RaidSuitable = false
LifeismysteryManaframe.Configuration.UnitSuitable = true
LifeismysteryManaframe.Configuration.FrameType = "Frame"
LifeismysteryManaframe.Configuration.Width = 250
LifeismysteryManaframe.Configuration.Height = 20
LifeismysteryManaframe.Configuration.Resizable = { 10, 10, 500, 100 }
LifeismysteryManaframe.Configuration.SupportsOwnBuffsPanel = false
LifeismysteryManaframe.Configuration.SupportsOwnDebuffsPanel = false
LifeismysteryManaframe.Configuration.SupportsExcludeBuffsPanel = false
LifeismysteryManaframe.Configuration.SupportsExcludeCastsPanel = false
LifeismysteryManaframe.Configuration.SupportsShowRadius = false
LifeismysteryManaframe.Configuration.SupportsShowCombo = false
LifeismysteryManaframe.Configuration.SupportsShowRankIconPanel = false


--------------------------------------------------------------
function LifeismysteryManaframe:Construct(options)
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
				border=true, 
				BorderColorBinding="BorderColorUnitFrame2", 
				BorderColorUnitFrame2 = {r=0,g=0,b=0,a=1},
			},	
			{
				id="barResource", type="BarHealth", parent="frameBackdrop", layer=11,
				attach = {
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=2, offsetY=2 },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-2, offsetY=-2 },
				},
				binding="resourcePercent", colorBinding="resourceColor",
				media="Texture 13",
				growthDirection="left",				
				backgroundColor={r=0.07, g=0.07, b=0.07, a=0.85},
			},				
		}
	}
	
	for idx,element in ipairs(template.elements) do
	    local showElement = true
		if options.shortname == true and element.id == "labelName" then 
			element.text = "{nameShort}"
		elseif	options.shortname == false and element.id == "labelName" then 	
			element.text = "{name}"
		end
		if not options.showname == true and element.id == "labelName" then showElement = false end
		if showElement then
			self:CreateElement(element)
		end
	end

	self:EventAttach(
		Event.UI.Layout.Size,
		function(el)
			local newWidth = self:GetWidth()
			local newHeight = self:GetHeight()
			local fracWidth = newWidth / LifeismysteryManaframe.Configuration.Width
			local fracHeight = newHeight / LifeismysteryManaframe.Configuration.Height
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