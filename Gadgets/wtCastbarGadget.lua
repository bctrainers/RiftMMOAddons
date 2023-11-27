--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.8.1
      Project Date (UTC)  : 2013-09-17T18:45:13Z
      File Modified (UTC) : 2013-09-16T14:06:04Z (lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier

local PHICON = "Data/\\UI\\texture\\global\\placeholder_icon.dds"

-- wtCastBar provides a simple bar for the player's cast bar

local function OnCastName(unitFrame, castname)
	if castname then
		local unit = unitFrame.Unit
		if unitFrame.icon then
			local cbd = Inspect.Unit.Castbar(unit.id)
			if cbd then
				if cbd.abilityNew then
					local ad = Inspect.Ability.New.Detail(cbd.abilityNew)
					if ad and ad.icon then
						unitFrame.icon:SetTexture("Rift", ad.icon)
					else
						unitFrame.icon:SetTexture("Rift", PHICON)
					end
				else
					unitFrame.icon:SetTexture("Rift", PHICON)
				end
			else
				WT.UnitDatabase.Casting[unit.id] = nil
				WT.Units[unit.id].castName = nil
			end
		end
		if unit.castUninterruptible then
			unitFrame.barCast.Image:SetTexture(unitFrame.mediaNoInterrupt.addonId, unitFrame.mediaNoInterrupt.filename)  
			unitFrame.barCast.Image:SetBackgroundColor(unitFrame.colorNoInterrupt[1], unitFrame.colorNoInterrupt[2], unitFrame.colorNoInterrupt[3], unitFrame.colorNoInterrupt[4])
		else
			unitFrame.barCast.Image:SetTexture(unitFrame.mediaInterrupt.addonId, unitFrame.mediaInterrupt.filename)  
			unitFrame.barCast.Image:SetBackgroundColor(unitFrame.colorInterrupt[1], unitFrame.colorInterrupt[2], unitFrame.colorInterrupt[3], unitFrame.colorInterrupt[4])
		end
	end
end

local function Create(configuration)

	local castBar = WT.UnitFrame:Create(configuration.unitSpec)
	castBar:SetWidth(170)
	castBar:SetHeight(24)
	if not configuration.hideNotCasting then
		castBar:SetBackgroundColor(0,0,0,0.4)
	end
	
	if configuration.cbColorInt == nil then configuration.cbColorInt = {0.42,0.69,0.81,1.0} end
	if configuration.cbColorNonInt == nil then configuration.cbColorNonInt = {0.9,0.7,0.3,1.0} end

	if configuration.TransparentCastBar == true then configuration.backgroundColor={r=0.07,g=0.07,b=0.07, a=0.85} end
	
	castBar.mediaInterrupt = Library.Media.GetTexture(configuration.texture)
	castBar.mediaNoInterrupt = Library.Media.GetTexture(configuration.textureNoInterrupt)

	castBar.colorInterrupt = configuration.cbColorInt
	castBar.colorNoInterrupt = configuration.cbColorNonInt
	
	castBar.font = Library.Media.GetFont(configuration.font)
	castBar.textFontSize = configuration.fontSize

	castBar.smallTimer = configuration.smallCastTime
	
	castBar.largeCastFont = configuration.largeCastFont
	
	castBar.barCast = castBar:CreateElement(
	{
		id="barCast", type="Bar", parent="frame", layer=25,
		attach = {
			{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
			{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" },
		},
		visibilityBinding="castName",
		binding="castPercent",
		media=configuration.texture, --colorBinding="castColor",
		backgroundColor=configuration.backgroundColor or {r=0, g=0, b=0, a=1},
	})
	if configuration.showCastName or configuration.showCastName == nil then
		if not configuration.CastNameAbove or configuration.CastNameAbove == nil then
			castBar.labelCast = castBar:CreateElement(
			{
				id="labelCast", type="Label", parent="frame", layer=26,
				attach = {{ point="CENTERLEFT", element="barCast", targetPoint="CENTERLEFT", offsetX=6, offsetY=0 }},
				visibilityBinding="castName",
				text="{castName}", default="", fontSize= configuration.fontSize, outline = true, font = configuration.font,
			})
			else
			castBar.labelCast = castBar:CreateElement(
			{
				id="labelCast", type="Label", parent="frame", layer=26,
				attach = {{ point="BOTTOMLEFT", element="frame", targetPoint="TOPLEFT", offsetX=0, offsetY=0 }},
				visibilityBinding="castName",
				text="{castName}", default="", fontSize= configuration.fontSize, outline = true, font = configuration.font,
			})
			end
	else
				castBar.labelCast = castBar:CreateElement(
			{
				id="labelCast", type="Label", parent="frame", layer=26,
				attach = {{ point="CENTERLEFT", element="barCast", targetPoint="CENTERLEFT", offsetX=6, offsetY=0 }},
				visibilityBinding="castName",
				text="", default="", fontSize= 0, font = configuration.font
			})	
	end
	
	if configuration.showCastTime then
		if not configuration.CastNameAbove or configuration.CastNameAbove == nil then	
			castBar.labelTime = castBar:CreateElement(
			{
				id="labelTime", type="Label", parent="frame", layer=26,
				attach = {{ point="CENTERRIGHT", element="frame", targetPoint="CENTERRIGHT", offsetX=-4, offsetY=0 }},
				visibilityBinding="castName",
				text="{castTime}", default="", fontSize= configuration.fontSize, outline = true, font = configuration.font,
			})
			
			if configuration.smallCastTime then
				castBar.labelTime:ClearAll()
				castBar.labelTime:SetPoint("CENTERRIGHT", castBar.barCast, "CENTERRIGHT", -4, 0)
			else
				castBar.labelTime:ClearAll()
				castBar.labelTime:SetPoint("CENTERRIGHT", castBar.barCast, "CENTERRIGHT", -4, 0)
			end
		else
			castBar.labelTime = castBar:CreateElement(
			{
				id="labelTime", type="Label", parent="frame", layer=26,
				attach = {{ point="BOTTOMRIGHT", element="barCast", targetPoint="TOPRIGHT", offsetX=-4, offsetY=0 }},
				visibilityBinding="castName",
				text="{castTime}", default="", fontSize= configuration.fontSize, outline = true, font = configuration.font,
			})
		end
		
		-- Mask out the label so it doesn't crash into the timer
		castBar.labelMask = UI.CreateFrame("Mask", "LabelMask", castBar)
		castBar.labelMask:SetLayer(26)
		castBar.labelMask:SetPoint("TOPLEFT", castBar.barCast, "TOPLEFT")
		castBar.labelMask:SetPoint("BOTTOM", castBar.barCast, "BOTTOM")
		castBar.labelMask:SetPoint("RIGHT", castBar.labelTime, "LEFT", -8, nil)
		
		--castBar.labelCast:SetParent(castBar.labelMask)
		
	end

	if configuration.showIcon then
		castBar.icon = castBar:CreateElement({
			id="abilityIcon", type="Image", parent="frame", layer=30,
			attach = {{ point = "TOPRIGHT", element="barCast", targetPoint = "TOPLEFT", offsetX=-2, offsetY=0 }},
			visibilityBinding="castName", texAddon="Rift", texFile=PHICON
		})
	end
	
    if configuration.Border then
	castBar.Border = castBar:CreateElement({
		id="CastbarBorder", type="Frame", parent="frame", layer=10,
		attach = {
			{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
			{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" },
		},
			visibilityBinding="castName", 
			color={r=0,g=0,b=0,a=0},
			BorderColorBinding="BorderColor3", border=true, BorderColor3 = {r=0,g=0,b=0,a=1},
	})
	end
	
	castBar.OnResize = 
		function(frame)		
		local fh = frame:GetHeight()
			local lg = 0.4
			if castBar.largeCastFont then lg = 0.5 end
			local s = math.floor(fh * lg)
			if s > 24 then
			s = 24
			end
			if configuration.showIcon then
				castBar.icon:SetHeight(fh)
				castBar.icon:SetWidth(fh)
			end
		end
	
	castBar.barCast:EventAttach(Event.UI.Layout.Size, function(self, h)
		castBar.OnResize(castBar)
	end, "Event.UI.Layout.Size")

	castBar:CreateBinding("castName", castBar, OnCastName, nil)

	castBar.barCast:SetVisible(false)

	return castBar, { resizable = { 140, 3, 1000, 300 } }
end

local dialog = false

local function ConfigDialog(container)

	local lMedia = Library.Media.FindMedia("bar")
	local listMedia = {}
	for mediaId, media in pairs(lMedia) do
		table.insert(listMedia, { ["text"]=mediaId, ["value"]=mediaId })
	end
	
	local lfont = Library.Media.GetFontIds("font")
	local listfont = {}
	for v, k in pairs(lfont) do
		table.insert(listfont, { value=k })
	end
	
	dialog = WT.Dialog(container)
		:Label("The cast bar gadget shows a cast bar for the unit selected.")
		:Combobox("unitSpec", "Unit to track", "player",
			{
				{text="Player", value="player"},
				{text="Target", value="player.target"},
				{text="Target's Target", value="player.target.target"},
				{text="Focus", value="focus"},
				{text="Focus's Target", value="focus.target"},
				{text="Pet", value="player.pet"},
			}, false)		
		:TexSelect("texture", "Texture", "Texture 82", "bar")
		:ColorPicker("cbColorInt", "Interruptible color", 0.42,0.69,0.81,1.0)
		:TexSelect("textureNoInterrupt", "Noninterruptable Texture", "Texture 87", "bar")
		:ColorPicker("cbColorNonInt", "Non-Interruptible color", 0.9,0.7,0.3,1.0)
		:Select("font", "Font", "#Default", lfont, true)
		:Slider("fontSize", "Font Size", 14, true)
		:Checkbox("hideNotCasting", "Hide when inactive", true)
		:Checkbox("showCastTime", "Show cast time", true)
		:Checkbox("showCastName", "Show cast name", true)
		:Checkbox("CastNameAbove", "Cast name above cast bar", false)
		:Checkbox("smallCastTime", "Small cast time text", false)
		:Checkbox("showIcon", "Show ability icon", false)
		:Checkbox("TransparentCastBar", "Transparent cast bar", true)
		:Checkbox("Border", "Show cast bar border", true)
		:Checkbox("largeCastFont", "Larger cast font", true)
		
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

local function Reconfigure(config)

	assert(config.id, "No id provided in reconfiguration details")
	
	local gadgetConfig = wtxGadgets[config.id]
	local gadget = WT.Gadgets[config.id]
	
	assert(gadget, "Gadget id does not exist in WT.Gadgets")
	assert(gadgetConfig, "Gadget id does not exist in wtxGadgets")
	assert(gadgetConfig.type == "CastBar", "Reconfigure Gadget is not a castbar")
	
	-- Detect changes to config and apply them to the gadget
	
	local requireRecreate = false
	
	if gadgetConfig.unitSpec ~= config.unitSpec then
		gadgetConfig.unitSpec = config.unitSpec
		requireRecreate = true
	end

	if gadgetConfig.texture ~= config.texture then
		gadgetConfig.texture = config.texture
		gadget.mediaInterrupt = Library.Media.GetTexture(config.texture)
	end

	if gadgetConfig.textureNoInterrupt ~= config.textureNoInterrupt then
		gadgetConfig.textureNoInterrupt = config.textureNoInterrupt
		gadget.mediaNoInterrupt = Library.Media.GetTexture(config.textureNoInterrupt)
	end

	if gadgetConfig.fontSize ~= config.fontSize then
		gadgetConfig.fontSize = config.fontSize
		gadget.textFontSize = config.fontSize
	end
	
	if gadgetConfig.hideNotCasting ~= config.hideNotCasting then
		gadgetConfig.hideNotCasting = config.hideNotCasting
		if not config.hideNotCasting then
			gadget:SetBackgroundColor(0,0,0,0.4)
		else
			gadget:SetBackgroundColor(0,0,0,0)
		end
	end

	if gadget.labelTime then
		if config.smallCastTime then
			gadget.labelTime:ClearAll()
			gadget.labelTime:SetPoint("BOTTOMRIGHT", gadget.barCast, "BOTTOMRIGHT", -4, -4)
		else
			gadget.labelTime:ClearAll()
			gadget.labelTime:SetPoint("CENTERRIGHT", gadget.barCast, "CENTERRIGHT", -4, 0)
		end
	end

	if gadgetConfig.showCastTime ~= config.showCastTime then
		gadgetConfig.showCastTime = config.showCastTime
		requireRecreate = true
	end
	
	if gadgetConfig.showCastName ~= config.showCastName then
		gadgetConfig.showCastName = config.showCastName
		requireRecreate = true
	end

	if gadgetConfig.CastNameAbove ~= config.CastNameAbove then
		gadgetConfig.CastNameAbove = config.CastNameAbove
		requireRecreate = true
	end	

	if gadgetConfig.smallCastTime ~= config.smallCastTime then
		gadgetConfig.smallCastTime = config.smallCastTime
		gadget.smallTimer = config.smallCastTime
		gadget:OnResize()
	end
	
	if gadgetConfig.showIcon ~= config.showIcon then
		gadgetConfig.showIcon = config.showIcon
		requireRecreate = true
	end

	if gadgetConfig.TransparentCastBar ~= config.TransparentCastBar then
		gadgetConfig.TransparentCastBar = config.TransparentCastBar
		requireRecreate = true
	end
	
	if gadgetConfig.Border ~= config.Border then
		gadgetConfig.Border = config.Border
		requireRecreate = true
	end
	
	if gadgetConfig.largeCastFont ~= config.largeCastFont then
		gadgetConfig.largeCastFont = config.largeCastFont
		gadget.largeCastFont = config.largeCastFont
		requireRecreate = true
	end
	
	if requireRecreate then
		WT.Gadget.Delete(gadgetConfig.id)
		WT.Gadget.Create(gadgetConfig)
	end		
	
end

WT.Unit.CreateVirtualProperty("BorderColor3", { "id", "castName"},
	function(unit)
		if unit.id and unit.castName then
			return  { r=0, g=0, b=0, a=1 }
		else
			return { r=0, g=0, b=0, a=0 }
		end
	end)
	
WT.Gadget.RegisterFactory("CastBar",
	{
		name="Castbar",
		description="Castbar",
		author="Wildtide/Adelea",
		version="1.1.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtCastBar.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
		["Reconfigure"] = Reconfigure,
	})