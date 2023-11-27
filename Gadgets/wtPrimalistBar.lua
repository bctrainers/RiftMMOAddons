--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            Lifeismystery@yandex.ru
                           Lifeismystery: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.10.3
      Project Date (UTC)  : 2015-10-13T23:42:32Z
      File Modified (UTC) : 2015-10-13T22:17:01Z (Lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate
	
local function Create(configuration)

	local primalistBar = WT.UnitFrame:Create("player")
	primalistBar.fontEntry = Library.Media.GetFont(configuration.font)
	primalistBar.textFontSize = configuration.fontSize
	primalistBar.presets = configuration.presets
	primalistBar.colorFury = configuration.colorFury or {0.66, 0.09, 0.09, 1.0}
	primalistBar.colorHarmony = configuration.colorHarmony or {0.20, 0.15, 0.09, 1.0}
	primalistBar.colorCunning = configuration.colorCunning or {0.26, 0.63, 0.73, 1.0} 
	
	primalistBar.canvasSettings = {
		angle = configuration.angle or 0,
		castbarIndent = 1, 
		stroke_Back = { r = 0, g = 0, b = 0, a = 1, thickness = 1 },
		fill_Back = { type = "solid", r = 0, g = 0, b = 0, a = 0.75 },
		stroke_bar = { r = 0.15, g = 0.61, b = 1, thickness = 0 },
		fill_ColorFury = { type = "solid", r = primalistBar.colorFury[1], g = primalistBar.colorFury[2], b = primalistBar.colorFury[3], a = primalistBar.colorFury[4] },
		fill_ColorHarmony = { type = "solid", r = primalistBar.colorHarmony[1], g = primalistBar.colorHarmony[2], b = primalistBar.colorHarmony[3], a = primalistBar.colorHarmony[4] },
		fill_ColorCunning = { type = "solid", r = primalistBar.colorCunning[1], g = primalistBar.colorCunning[2], b = primalistBar.colorCunning[3], a = primalistBar.colorCunning[4] },
		--[[fill = {type = "gradientLinear",  --transform = {1, 0, 0, 0, 1, 0},
			color = {
			{r = primalistBar.colorFury[1], g = primalistBar.colorFury[2], b = primalistBar.colorFury[3], a = primalistBar.colorFury[4], 	position = 0},
			--{r = primalistBar.colorFury[1], g = primalistBar.colorFury[2], b = primalistBar.colorFury[3], a = primalistBar.colorFury[4], 	position = 0.4},
			{r = primalistBar.colorHarmony[1], g = primalistBar.colorHarmony[2], b = primalistBar.colorHarmony[3], a = primalistBar.colorHarmony[4], 	position = 0.8 + 1/primalistBar:GetWidth()},
			--{r = primalistBar.colorHarmony[1], g = primalistBar.colorHarmony[2], b = primalistBar.colorHarmony[3], a = primalistBar.colorHarmony[4], 	position = 0.5},
			--{r = primalistBar.colorCunning[1], g = primalistBar.colorCunning[2], b = primalistBar.colorCunning[3], a = primalistBar.colorCunning[4], 	position =0.6},
			{r = primalistBar.colorCunning[1], g = primalistBar.colorCunning[2], b = primalistBar.colorCunning[3], a = primalistBar.colorCunning[4], 	position = 1 + 1/primalistBar:GetWidth()},
			}},
			]]
	}
	
	--primalistBar:SetWidth(200)
	--primalistBar:SetHeight(20)
	
	-----------------------------------Bar------------------------------------------------
	primalistBar.Backdrop = UI.CreateFrame("Canvas", "Backdrop", primalistBar)
	primalistBar.Backdrop:SetPoint("TOPLEFT", primalistBar, "TOPLEFT", 0, 0)
	primalistBar.Backdrop:SetPoint("BOTTOMRIGHT", primalistBar, "BOTTOMRIGHT", 0, 0)
	primalistBar.Backdrop:SetLayer(1)
	primalistBar.Backdrop:SetVisible(true)
	
	
	primalistBar.OnResize = function()
		local tg = math.tan(primalistBar.canvasSettings.angle * math.pi / 180)
		local offset = tg * primalistBar:GetHeight() / primalistBar:GetWidth() / 2
		local indentOffset = tg * primalistBar.canvasSettings.castbarIndent / primalistBar:GetWidth()
		primalistBar.realWidth = primalistBar:GetWidth() - math.abs(tg * primalistBar:GetHeight()) - primalistBar.canvasSettings.castbarIndent * 2

		primalistBar.canvasSettings.path = { 
			{ xProportional = math.abs(offset) - offset, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset) - offset, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset) + offset, yProportional = 1 },
			{ xProportional = math.abs(offset) + offset, yProportional = 1 },
			{ xProportional = math.abs(offset) - offset, yProportional = 0 },
		}
		primalistBar.canvasSettings.pathCastbar = { 
			{ xProportional = math.abs(offset) - offset + indentOffset, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset) - offset + indentOffset, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset) + offset - indentOffset, yProportional = 1 },
			{ xProportional = math.abs(offset) + offset - indentOffset, yProportional = 1 },
			{ xProportional = math.abs(offset) - offset + indentOffset, yProportional = 0 },
		}
		primalistBar.canvasSettings.fill = {
			type = "gradientLinear",  
			transform = { primalistBar:GetWidth()/100, 0, 0, 0, 1, 0},
			color = {
			{r = primalistBar.colorFury[1], g = primalistBar.colorFury[2], b = primalistBar.colorFury[3], a = primalistBar.colorFury[4], 	position = 0},
			{r = primalistBar.colorHarmony[1], g = primalistBar.colorHarmony[2], b = primalistBar.colorHarmony[3], a = primalistBar.colorHarmony[4], 	position = 0.5},
			{r = primalistBar.colorHarmony[1], g = primalistBar.colorHarmony[2], b = primalistBar.colorHarmony[3], a = primalistBar.colorHarmony[4], 	position = 0.6},
			{r = primalistBar.colorCunning[1], g = primalistBar.colorCunning[2], b = primalistBar.colorCunning[3], a = primalistBar.colorCunning[4], 	position = 1},
			}
		}
		primalistBar.Backdrop:SetShape(primalistBar.canvasSettings.path, primalistBar.canvasSettings.fill, primalistBar.canvasSettings.stroke_Back)
		--primalistBar.barMask:SetShape(primalistBar.canvasSettings.pathCastbar)
		--primalistBar.barCast:SetShape(primalistBar.canvasSettings.pathCastbar, primalistBar.canvasSettings.fillCastbar, primalistBar.canvasSettings.strokeCastbar)
	end

	primalistBar.OnResize()
	
	-----------------------------------Text-----------------------------------------------
	primalistBar.slider = UI.CreateFrame("Canvas", "slider", primalistBar)
	primalistBar.slider:SetLayer(5)
	primalistBar.slider:SetWidth(30)
	primalistBar.slider:SetHeight(30)
	--primalistBar.slider:SetTexture(AddonId, "img/slider.png")
	primalistBar.slider:SetPoint("CENTERTOP", primalistBar, "CENTERTOP",0, -15)
	primalistBar.slider.path = { 
			{ xProportional = 0, yProportional = 0 },
			{ xProportional = 0.3, yProportional = 0 },
			{ xProportional = 0.5, yProportional = 0.2 },
			{ xProportional = 0.7, yProportional = 0 },
			{ xProportional = 1, yProportional = 0 },
			{ xProportional = 0.5, yProportional = 0.5 },
			{ xProportional = 0, yProportional = 0 },
		}
	primalistBar.slider:SetShape(primalistBar.slider.path, primalistBar.canvasSettings.fill_Back, primalistBar.canvasSettings.stroke_Back)
	
	primalistBar.labelFocus = UI.CreateFrame("Text", "labelFocus", primalistBar)
	primalistBar.labelFocus:SetLayer(5)
	primalistBar.labelFocus:SetText("")
	primalistBar.labelFocus:SetEffectGlow({ strength = 3 })
	primalistBar.labelFocus:SetFontSize(primalistBar.textFontSize or 16)
	primalistBar.labelFocus:SetFont(primalistBar.fontEntry.addonId, primalistBar.fontEntry.filename)
	primalistBar.labelFocus:SetPoint("CENTERTOP", primalistBar.slider, "CENTERTOP",0, - 20)
	
	local width = primalistBar:GetWidth()/20
				  primalistBar.top = UI.CreateFrame("Texture", "TopBorder", primalistBar)
				  primalistBar.top:SetBackgroundColor(0,0,0,0)
				  primalistBar.top:SetLayer(1)
				  primalistBar.top:ClearAll()
				  primalistBar.top:SetPoint("BOTTOMLEFT", primalistBar, "TOPLEFT", -1, 0)
				  primalistBar.top:SetPoint("BOTTOMRIGHT", primalistBar, "TOPRIGHT", 1, 0)
				  primalistBar.top:SetHeight(2)
				  primalistBar.top:SetTexture("Gadgets", "img/wb.png")
				  primalistBar.top:SetVisible(false)
				  
				  primalistBar.bottom = UI.CreateFrame("Texture", "BottomBorder", primalistBar)
				  primalistBar.bottom:SetBackgroundColor(0,0,0,0)
				  primalistBar.bottom:SetLayer(1)
				  primalistBar.bottom:ClearAll()
				  primalistBar.bottom:SetPoint("TOPLEFT", primalistBar, "BOTTOMLEFT", -1, 0)
				  primalistBar.bottom:SetPoint("TOPRIGHT", primalistBar, "BOTTOMRIGHT",1, 0)
				  primalistBar.bottom:SetHeight(2)
				  primalistBar.bottom:SetTexture("Gadgets", "img/wt.png")
				  primalistBar.bottom:SetVisible(false)
				  
				  primalistBar.left = UI.CreateFrame("Texture", "LeftBorder", primalistBar)
				  primalistBar.left:SetBackgroundColor(0,0,0,0)
				  primalistBar.left:SetLayer(1)
				  primalistBar.left:ClearAll()
				  primalistBar.left:SetPoint("TOPRIGHT", primalistBar, "TOPLEFT", 0, -1)
				  primalistBar.left:SetPoint("BOTTOMRIGHT", primalistBar, "BOTTOMLEFT", 0, 1)
				  primalistBar.left:SetWidth(2)
				  primalistBar.left:SetTexture("Gadgets", "img/wr.png")
				  primalistBar.left:SetVisible(false)
				  
				  primalistBar.right = UI.CreateFrame("Texture", "RightBorder", primalistBar)
				  primalistBar.right:SetBackgroundColor(0,0,0,0)
				  primalistBar.right:SetLayer(1)
				  primalistBar.right:ClearAll()
				  primalistBar.right:SetPoint("TOPLEFT", primalistBar, "TOPRIGHT", 0, -1)
				  primalistBar.right:SetPoint("BOTTOMLEFT", primalistBar, "BOTTOMRIGHT", 0, 1)
				  primalistBar.right:SetWidth(2)
				  primalistBar.right:SetTexture("Gadgets", "img/wl.png")
				  primalistBar.right:SetVisible(false)
				  
local function PrimalistBarOnSystemUpdateBegin()

	local detail = Inspect.Unit.Detail("player")
	--if detail then local primalistFocus = detail.focus end
		if detail.focus  then
			if detail.focus < 100 then
				primalistFocus = 100 - detail.focus
				primalistBar.labelFocus:SetText(tostring(primalistFocus))
				primalistBar.labelFocus:SetFontColor(0.66, 0.09, 0.09, 1.0)
				primalistBar.slider:SetPoint("CENTERTOP", primalistBar, "CENTERTOP",-width*primalistFocus, -15)
				if detail.focus == 0 then
					primalistBar.labelFocus:SetFontColor(1, 0, 0, 1)
					primalistBar.top:SetBackgroundColor(1,0,0,1)
					primalistBar.bottom:SetBackgroundColor(1,0,0,1)
					primalistBar.left:SetBackgroundColor(1,0,0,1)
					primalistBar.right:SetBackgroundColor(1,0,0,1)
					primalistBar.top:SetVisible(true)
					primalistBar.bottom:SetVisible(true)
					primalistBar.left:SetVisible(true)
					primalistBar.right:SetVisible(true)
				else
					primalistBar.labelFocus:SetFontColor(0.66, 0.09, 0.09, 1.0)
					primalistBar.top:SetVisible(false)
					primalistBar.bottom:SetVisible(false)
					primalistBar.left:SetVisible(false)
					primalistBar.right:SetVisible(false)				
				end
			elseif detail.focus == 100 then
				primalistFocus = detail.focus - 100
				primalistBar.labelFocus:SetText(tostring(primalistFocus))
				primalistBar.labelFocus:SetFontColor(0.20, 0.15, 0.09, 1.0)
				primalistBar.slider:SetPoint("CENTERTOP", primalistBar, "CENTERTOP",0, -15)
			else 
				primalistFocus = detail.focus - 100
				primalistBar.labelFocus:SetText(tostring(primalistFocus))
				primalistBar.labelFocus:SetFontColor(0.26, 0.63, 0.73, 1.0)
				primalistBar.slider:SetPoint("CENTERTOP", primalistBar, "CENTERTOP",width*primalistFocus, -15)
				if detail.focus == 200 then
					primalistBar.labelFocus:SetFontColor(0, 0.73, 0.73, 1.0)
					primalistBar.top:SetBackgroundColor(0,1,1,1)
					primalistBar.bottom:SetBackgroundColor(0,1,1,1)
					primalistBar.left:SetBackgroundColor(0,1,1,1)
					primalistBar.right:SetBackgroundColor(0,1,1,1)
					primalistBar.top:SetVisible(true)
					primalistBar.bottom:SetVisible(true)
					primalistBar.left:SetVisible(true)
					primalistBar.right:SetVisible(true)
				else
					primalistBar.labelFocus:SetFontColor(0.26, 0.63, 0.73, 1.0)
					primalistBar.top:SetVisible(false)
					primalistBar.bottom:SetVisible(false)
					primalistBar.left:SetVisible(false)
					primalistBar.right:SetVisible(false)
				end
			end
		else 	
		primalistBar.labelFocus:SetText("")
	end
end
Command.Event.Attach(Event.System.Update.Begin,	PrimalistBarOnSystemUpdateBegin, "PrimalistBarOnSystemUpdateBegin")

				  
	return primalistBar, { resizable = { 200, 5, 500, 50 } }
end

local function Reconfigure(config)

	assert(config.id, "No id provided in reconfiguration details")
	
	local gadgetConfig = wtxGadgets[config.id]
	local gadget = WT.Gadgets[config.id]
	
	assert(gadget, "Gadget id does not exist in WT.Gadgets")
	assert(gadgetConfig, "Gadget id does not exist in wtxGadgets")
	assert(gadgetConfig.type == "PrimaistBar", "Reconfigure Gadget is not a primalist bar")
	
	-- Detect changes to config and apply them to the gadget
	
	local requireRecreate = false
	
	if gadgetConfig.fontSize ~= config.fontSize then
		gadgetConfig.fontSize = config.fontSize
		gadget.textFontSize = config.fontSize
	end
	
	if gadgetConfig.font ~= config.font then
		gadgetConfig.font = config.font
	end

	if gadgetConfig.presets ~= config.presets then
		gadgetConfig.presets = config.presets
		gadget.presets = config.presets
	end	
end

local dialog = false

local function ConfigDialog(container)

	local lfont = Library.Media.GetFontIds("font")
	local listfont = {}
	for v, k in pairs(lfont) do
		table.insert(listfont, { value=k })
	end	
	
	dialog = WT.Dialog(container)
		:Label("Primalist Bar")
		:Select("font", "Font", "#Default", lfont, true)
		:Slider("fontSize", "Font Size", 16, true)
		:Combobox("presets", "Presets:", "standart",
			{
				{text="Standart", value="standart"},
				{text="Minimalist", value="minimalist"},
				{text="Only numbers", value="only_numbers"},
			}, false)
		:ColorPicker("colorFury", "color Fury", 0.66, 0.09, 0.09, 1.0 )
		:ColorPicker("colorHarmony", "color Harmony", 0.20, 0.15, 0.09, 1.0 )
		:ColorPicker("colorCunning", "color Cunning",0.26, 0.63, 0.73, 1.0 )
		end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

WT.Gadget.RegisterFactory("PrimalistBar",
	{
		name="PrimalistBar",
		description="Primalist Bar",
		author="Lifeismystery",
		version="1.0",
		iconTexAddon=AddonId,
		iconTexFile="img/primalist.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})
