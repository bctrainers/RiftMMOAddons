
local toc, spd_priv = ...
local AddonId = toc.identifier

local playerFrame = WT.UnitFrame:Create("player")
local SpeedometerIndicators = {}
local PreviousCoords = {}
local showMPH = false
local showRPS = false
local showIcon = false
local showBkgrd = false
local cfg_dialog = false
local updateInterval = 0.25
local last_update = 0
local spd_100pct = 5.0  
local spd_fontSize = 18
local spd_total_speed = 0
local spd_total_updates = 0
local DEFAULT_RIFT_FONT = ""

Library.Media.AddFont("wwDigital", AddonId, "img/wwDigital.ttf")
Library.Media.AddFont("liQuid", AddonId, "img/liquid.ttf")
Library.Media.AddFont("liQuidExB", AddonId, "img/LiquidExBold.ttf")
Library.Media.AddFont("liQuidB", AddonId, "LiQuidBold.ttf")
local spd_font = "wwDigital"

local function ups_to_mph(speed_in_rups)  --"rups" = rift units per second
	if speed_in_rups ~= nil then
		ru_to_mtrs = 1.03
		mtrs_per_mi = 1609.34
		return string.format("%04.1f", speed_in_rups/ru_to_mtrs/mtrs_per_mi * 3600)
	end
	return "00.0"
end

local function OnCoordChange(spd_indicator, new_coord)
	local now = Inspect.Time.Real()
	local z_adjustment = .7   															--things are a bit crazy when going up and down
	local new_pct_readout = "000"
	local current_speed = 0
	local avg_speed = 0
	local d_time, d_z, d_y, d_x = nil

	if now - last_update > updateInterval then
		last_update = now
		if new_coord[1] ~= nil then
			if table.getn(PreviousCoords) > 1 then
				d_time = now - table.remove(PreviousCoords)
				d_z	 = new_coord[3] - table.remove(PreviousCoords)
				d_y	 = (new_coord[2] - table.remove(PreviousCoords)) * z_adjustment  	--y is actually z and z is y in the unit.coords
				d_x	 = new_coord[1] - table.remove(PreviousCoords)
				current_speed = math.sqrt(d_x * d_x + d_y * d_y + d_z * d_z)/d_time
				if current_speed > 0 then
					spd_total_updates = spd_total_updates + 1
					spd_total_speed = spd_total_speed + current_speed
					avg_speed = spd_total_speed/spd_total_updates
					new_pct_readout = string.format("%03d", avg_speed/spd_100pct * 100)
					if spd_total_updates > 4 and current_speed < avg_speed - 2.1 or current_speed > avg_speed + 2.1 then	--someone jumped off his/her mount or is toggling walk/run
						spd_total_updates = 0
						spd_total_speed = 0
						avg_speed = 0
					end
				end
			end
		else
			for k,v in pairs(PreviousCoords) do PreviousCoords[k] = nil end
			return nil
		end
		table.insert(PreviousCoords,new_coord[1])
		table.insert(PreviousCoords,new_coord[2])
		table.insert(PreviousCoords,new_coord[3])
		table.insert(PreviousCoords,now)

		if showMPH == true then
			spd_indicator.MphText2:SetText(ups_to_mph(avg_speed))
			spd_indicator.MphText:SetText(ups_to_mph(avg_speed))
		end
		if showRPS == true then		
			local avg_speed_text = string.format("%04.1f", avg_speed)		
			spd_indicator.RpsText2:SetText(avg_speed_text)
			spd_indicator.RpsText:SetText(avg_speed_text)
		end
		if showIcon == true then
			for k, v in pairs(spd_indicator.imgSpeedIcon) do v:SetVisible(false) end
			if current_speed < 8 then spd_indicator.imgSpeedIcon[2]:SetVisible(true)
			elseif current_speed < 11 then spd_indicator.imgSpeedIcon[3]:SetVisible(true)
			elseif current_speed < 15 then spd_indicator.imgSpeedIcon[4]:SetVisible(true)
			else spd_indicator.imgSpeedIcon[5]:SetVisible(true)
			end
		end
		spd_indicator.SpdText:SetText(new_pct_readout)
		spd_indicator.SpdText2:SetText(new_pct_readout)
	end
end


function FontSelection(parent, label, default, listItems, sort)     					--all font selection work is pretty much taken directly from Adelea's Gadgets_SCT addon-thanks!
	local control = UI.CreateFrame("Frame", WT.UniqueName("Control"), parent)
	control.frameIndex = getmetatable(control).__index
	setmetatable(control, WT.Control.ComboBox_mt)

	local tfValue = UI.CreateFrame("RiftTextfield", WT.UniqueName("GadgetControlUnitSpecSelector_TextField"), control)
	tfValue:SetText(default or "")
	tfValue:SetBackgroundColor(0.2,0.2,0.2,0.9)
	control.TextField = tfValue

	if label then
		local txtLabel = UI.CreateFrame("Text", WT.UniqueName("GadgetControlUnitSpecSelector_Label"), control)
		txtLabel:SetText(label)
		txtLabel:SetPoint("TOPLEFT", control, "TOPLEFT")
		tfValue:SetPoint("CENTERLEFT", txtLabel, "CENTERRIGHT", 8, 0)
	else
		tfValue:SetPoint("TOPLEFT", control, "TOPLEFT", 0, 0)
	end

	local dropDownIcon = UI.CreateFrame("Texture", WT.UniqueName("GadgetControlUnitSpecSelector_Dropdown"), tfValue)
	dropDownIcon:SetTexture("wtLibGadget", "img/wtDropDown.png")
	dropDownIcon:SetHeight(tfValue:GetHeight())
	dropDownIcon:SetWidth(tfValue:GetHeight())
	dropDownIcon:SetPoint("TOPLEFT", tfValue, "TOPRIGHT", -10, 0)

	local menu = WT.Control.Menu.Create(parent, listItems, function(value) control:SetText(value) end, sort)
	menu:SetPoint("TOPRIGHT", dropDownIcon, "BOTTOMCENTER")

	local fontList = Library.Media.ListFonts()

	for k,v in pairs(menu.items) do
		if fontList[v:GetText()] == nil then
			v:SetFont("Rift", "wwDigital")
		else
			local fontDtl = Library.Media.GetFont(v:GetText())
			v:SetFont(fontDtl.addonId, fontDtl.filename)
		end
	end

	dropDownIcon.Event.LeftClick = function() menu:Toggle() end

	control.GetText = function() return tfValue:GetText() end
	control.SetText =
		function(ctrl, value)
			tfValue:SetText(tostring(value))
		end

	control:SetHeight(20)

	return control

end

local function ConfigDialog(container)
	cfg_dialog = WT.Dialog(container)
		:Label("A simple indicator of how fast you're moving relative to original character run speed.")
		:ColorPicker("bg_clr", "Font Background Color", 0.9, 0.0, 0.0, 1)
		:ColorPicker("fg_clr", "Font Foreground Color", 0.9, 0.9, 0.9, 1)
		:ColorPicker("frm_bg_clr", "Backdrop Color", 0.0, 0.0, 0.0, .4)
		:Checkbox("showMPH", "Show speed in MPH too", true)
		:Checkbox("showRPS", "Show speed in Rift Units/sec too", true)		
		:Checkbox("showIcon", "Show Icon", true)
		:Checkbox("showBkgrd", "Show Background", true)

	local fontList = Library.Media.ListFonts()
	local fonts = {}
	for k,v in pairs(fontList) do
		table.insert(fonts, {text=k, value=k})
	end
	table.sort(fonts, function(a,b) return a.text < b.text end)
	frmConfig = UI.CreateFrame("Frame", "myConfig", container)
	frmConfig:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 190)
	frmConfig:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, -32)	
	spdFonts = FontSelection(container, "Select Font:", "wwDigital", fonts, nil)
	spdFonts:SetPoint("TOPLEFT", frmConfig, "TOPLEFT", 0, 4)
	spdFonts:SetText("wwDigital")
	cfg_dialog.font = spdFonts:GetText()
end

local function GetConfiguration()
	config = cfg_dialog:GetValues()
	config.font= spdFonts:GetText()
	return config
end

local function SetConfiguration(config)
	if Library.Media.GetFont(config.font) == nil then
		config.font= "wwDigital"
	end
	spdFonts:SetText(config.font)
	cfg_dialog:SetValues(config)
end

local function Create(cfg)

	local font = Library.Media.GetFont(cfg.font)
	if font == nil then
		cfg.font = DEFAULT_RIFT_FONT
		font = {addonId = "Rift", filename = "wwDigital"}
	end
	spd_font = cfg.font
	
	showMPH = cfg.showMPH
	showRPS = cfg.showRPS
	showIcon = cfg.showIcon
	showBkgrd = cfg.showBkgrd
	
	local pctTxtRgt = 40
	local pctLblLft = pctTxtRgt + -2
	local rpsTxtRgt = pctTxtRgt + 59
	local rpsLblLft = pctTxtRgt + 56	
	local mphTxtRgt = rpsTxtRgt
	local mphLblLft = rpsLblLft
	local label_width = 60
	local label_height = spd_fontSize + 10
	if showMPH == true then label_width = label_width + 72 end
	if showRPS == true then 
		label_width = label_width + 72
		mphTxtRgt = rpsTxtRgt + 70
		mphLblLft = rpsTxtRgt + 67
	end	

	local spd_indicator = WT.UnitFrame:Create("player")
	spd_indicator:SetWidth(label_width)
	spd_indicator:SetHeight(label_height)
	spd_indicator:SetLayer(100)
	spd_indicator.imgSpeedIcon = {}

	if showBkgrd == true then
		spd_indicator.frameBackdrop = spd_indicator:CreateElement(
			{
			id = "frameBackdrop", type = "Frame", parent = "spd_indicator", layer = 1, alpha = 1,
			attach = {{ point = "TOPLEFT", element = "frame", targetPoint = "TOPLEFT", offsetX = -10, offsetY = 1, },
					{ point = "BOTTOMRIGHT", element = "frame", targetPoint = "BOTTOMRIGHT", offsetX = -1, offsetY = -1, }
			},
			color = {r = cfg.frm_bg_clr[1], g = cfg.frm_bg_clr[2], b = cfg.frm_bg_clr[3]}, alpha = cfg.frm_bg_clr[4],
			}
		)
	end

	spd_indicator.SpdText2 = spd_indicator:CreateElement(
		{
		id = "SpdText2", type = "Label", parent = "frame", layer = 90,
		attach = {{ point = "CENTERRIGHT", element = "frame", targetPoint = "CENTERLEFT", offsetX = pctTxtRgt - 1, offsetY = -1}},
		text = "000", fontSize = spd_fontSize, font = spd_font, color = {r = cfg.bg_clr[1], g = cfg.bg_clr[2], b = cfg.bg_clr[3]}, alpha = cfg.bg_clr[4],
		width = label_width, height = label_height,
		}
	)
	spd_indicator.SpdText = spd_indicator:CreateElement(
		{
		id = "SpdText", type = "Label", parent = "frame", layer = 100,
		attach = {{ point = "CENTERRIGHT", element = "frame", targetPoint = "CENTERLEFT", offsetX = pctTxtRgt - 0, offsetY = 0 }},
		text = "000", fontSize = spd_fontSize, font = spd_font, color = {r = cfg.fg_clr[1], g = cfg.fg_clr[2], b = cfg.fg_clr[3]}, alpha = cfg.fg_clr[4],
		width = label_width, height = label_height,
		}
	)

	spd_indicator.MphText2 = spd_indicator:CreateElement(
		{
		id = "MphText2", type = "Label", parent = "spd_indicator", layer = 90,
		attach = {{ point = "CENTERRIGHT", element = "frame", targetPoint = "CENTERLEFT", offsetX = mphTxtRgt - 3, offsetY = -1}},
		text = "00.0", fontSize = spd_fontSize, font = spd_font, color = {r = cfg.bg_clr[1], g = cfg.bg_clr[2], b = cfg.bg_clr[3]}, alpha = cfg.bg_clr[4],
		}
	)
	spd_indicator.MphText = spd_indicator:CreateElement(
		{
		id = "MphText", type = "Label", parent = "spd_indicator", layer = 100,
		attach = {{ point = "CENTERRIGHT", element = "frame", targetPoint = "CENTERLEFT", offsetX = mphTxtRgt - 2, offsetY = 0}},
		text = "00.0", fontSize = spd_fontSize, font = spd_font, color = {r = cfg.fg_clr[1], g = cfg.fg_clr[2], b = cfg.fg_clr[3]}, alpha = cfg.fg_clr[4],
		}
	)
	
	spd_indicator.RpsText2 = spd_indicator:CreateElement(
		{
		id = "RpsText2", type = "Label", parent = "spd_indicator", layer = 90,
		attach = {{ point = "CENTERRIGHT", element = "frame", targetPoint = "CENTERLEFT", offsetX = rpsTxtRgt - 3, offsetY = -1}},
		text = "00.0", fontSize = spd_fontSize, font = spd_font, color = {r = cfg.bg_clr[1], g = cfg.bg_clr[2], b = cfg.bg_clr[3]}, alpha = cfg.bg_clr[4],
		}
	)
	spd_indicator.RpsText = spd_indicator:CreateElement(
		{
		id = "RpsText", type = "Label", parent = "spd_indicator", layer = 100,
		attach = {{ point = "CENTERRIGHT", element = "frame", targetPoint = "CENTERLEFT", offsetX = rpsTxtRgt - 2, offsetY = 0}},
		text = "00.0", fontSize = spd_fontSize, font = spd_font, color = {r = cfg.fg_clr[1], g = cfg.fg_clr[2], b = cfg.fg_clr[3]}, alpha = cfg.fg_clr[4],
		}
	)
	
	spd_indicator.PctLbl2 = spd_indicator:CreateElement(
		{
		id = "PctLbl2", type = "Label", parent = "frame", layer = 90,
		attach = {{ point = "CENTERLEFT", element = "frame", targetPoint = "CENTERLEFT", offsetX = pctLblLft - 1, offsetY = 1}},
		text = "%", fontSize = spd_fontSize - 2, font = spd_font, color = {r = cfg.bg_clr[1], g = cfg.bg_clr[2], b = cfg.bg_clr[3]}, alpha = cfg.bg_clr[4],
		width = label_width, height = label_height,
		}
	)
	spd_indicator.PctLbl = spd_indicator:CreateElement(
		{
		id = "PctLbl", type = "Label", parent = "frame", layer = 100,
		attach = {{ point = "CENTERLEFT", element = "frame", targetPoint = "CENTERLEFT", offsetX = pctLblLft - 0, offsetY = 2 }},
		text = "%", fontSize = spd_fontSize - 2, font = spd_font, color = {r = cfg.fg_clr[1], g = cfg.fg_clr[2], b = cfg.fg_clr[3]}, alpha = cfg.fg_clr[4],
		width = label_width, height = label_height,
		}
	)
	
	spd_indicator.MphLbl2 = spd_indicator:CreateElement(
		{
		id = "MphLbl2", type = "Label", parent = "frame", layer = 90,
		attach = {{ point = "CENTERLEFT", element = "frame", targetPoint = "CENTERLEFT", offsetX = mphLblLft - 1, offsetY = 1}},
		text = "mph", fontSize = spd_fontSize - 2, font = spd_font, color = {r = cfg.bg_clr[1], g = cfg.bg_clr[2], b = cfg.bg_clr[3]}, alpha = cfg.bg_clr[4],
		width = label_width, height = label_height,
		}
	)
	spd_indicator.MphLbl = spd_indicator:CreateElement(
		{
		id = "MphLbl", type = "Label", parent = "frame", layer = 100,
		attach = {{ point = "CENTERLEFT", element = "frame", targetPoint = "CENTERLEFT", offsetX = mphLblLft - 0, offsetY = 2 }},
		text = "mph", fontSize = spd_fontSize - 2, font = spd_font, color = {r = cfg.fg_clr[1], g = cfg.fg_clr[2], b = cfg.fg_clr[3]}, alpha = cfg.fg_clr[4],
		width = label_width, height = label_height,
		}
	)

	spd_indicator.RpsLbl2 = spd_indicator:CreateElement(
		{
		id = "RpsLbl2", type = "Label", parent = "frame", layer = 90,
		attach = {{ point = "CENTERLEFT", element = "frame", targetPoint = "CENTERLEFT", offsetX = rpsLblLft -1, offsetY = 1}},
		text = "rps", fontSize = spd_fontSize - 2, font = spd_font, color = {r = cfg.bg_clr[1], g = cfg.bg_clr[2], b = cfg.bg_clr[3]}, alpha = cfg.bg_clr[4],
		width = label_width, height = label_height,
		}
	)
	spd_indicator.RpsLbl = spd_indicator:CreateElement(
		{
		id = "RpsLbl", type = "Label", parent = "frame", layer = 100,
		attach = {{ point = "CENTERLEFT", element = "frame", targetPoint = "CENTERLEFT", offsetX = rpsLblLft - 0, offsetY = 2 }},
		text = "rps", fontSize = spd_fontSize - 2, font = spd_font, color = {r = cfg.fg_clr[1], g = cfg.fg_clr[2], b = cfg.fg_clr[3]}, alpha = cfg.fg_clr[4],
		width = label_width, height = label_height,
		}
	)
	
	if showMPH == false then
		spd_indicator.MphText2:SetVisible(false)
		spd_indicator.MphText:SetVisible(false)
		spd_indicator.MphLbl2:SetVisible(false)
		spd_indicator.MphLbl:SetVisible(false)
	end
	if showRPS == false then
		spd_indicator.RpsText2:SetVisible(false)
		spd_indicator.RpsText:SetVisible(false)
		spd_indicator.RpsLbl2:SetVisible(false)
		spd_indicator.RpsLbl:SetVisible(false)
	end
	
	local icon_offsetY = 0
	local icon_offsetX = -12
	spd_indicator.imgSpeedIcon[1] = spd_indicator:CreateElement(
	{
		id = "imgSpeedIcon1", type = "Image", parent = "frame", layer = 100, alpha = 1.0,
		attach = {{ point = "CENTER", element = "frame", targetPoint = "CENTERLEFT", offsetX = icon_offsetX, offsetY = icon_offsetY}},
		texAddon = AddonId, texFile = "img/speed_0.png",
		width = 28, height = 28,
		backgroundColor = {r = 0, g = 0, b = 0, a = 0.4}
	})
	spd_indicator.imgSpeedIcon[2] = spd_indicator:CreateElement(
	{
		id = "imgSpeedIcon2", type = "Image", parent = "frame", layer = 100, alpha = 1.0,
		attach = {{ point = "CENTER", element = "frame", targetPoint = "CENTERLEFT", offsetX = icon_offsetX, offsetY = icon_offsetY}},
		texAddon = AddonId, texFile = "img/speed_1.png",
		width = 28, height = 28,
		backgroundColor = {r = 0, g = 0, b = 0, a = 0.4}
	})
	spd_indicator.imgSpeedIcon[3] = spd_indicator:CreateElement(
	{
		id = "imgSpeedIcon3", type = "Image", parent = "frame", layer = 100, alpha = 1.0,
		attach = {{ point = "CENTER", element = "frame", targetPoint = "CENTERLEFT", offsetX = icon_offsetX, offsetY = icon_offsetY}},
		texAddon = AddonId, texFile = "img/speed_2.png",
		width = 28, height = 28,
		backgroundColor = {r = 0, g = 0, b = 0, a = 0.4}
	})
	spd_indicator.imgSpeedIcon[4] = spd_indicator:CreateElement(
	{
		id = "imgSpeedIcon4", type = "Image", parent = "frame", layer = 100, alpha = 1.0,
		attach = {{ point = "CENTER", element = "frame", targetPoint = "CENTERLEFT", offsetX = icon_offsetX, offsetY = icon_offsetY}},
		texAddon = AddonId, texFile = "img/speed_3.png",
		width = 28, height = 28,
		backgroundColor = {r = 0, g = 0, b = 0, a = 0.4}
	})
	spd_indicator.imgSpeedIcon[5] = spd_indicator:CreateElement(
	{
		id = "imgSpeedIcon5", type = "Image", parent = "frame", layer = 100, alpha = 1.0,
		attach = {{ point = "CENTER", element = "frame", targetPoint = "CENTERLEFT", offsetX = icon_offsetX, offsetY = icon_offsetY}},
		texAddon = AddonId, texFile = "img/speed_4.png",
		width = 28, height = 28,
		backgroundColor = {r = 0, g = 0, b = 0, a = 0.4}
	})
	for k, v in pairs(spd_indicator.imgSpeedIcon) do v:SetVisible(false) end
	if (showIcon == true) then spd_indicator.imgSpeedIcon[1]:SetVisible(true) end	

	spd_indicator:CreateBinding("coord", spd_indicator, OnCoordChange, nil)
	table.insert(SpeedometerIndicators, spd_indicator)
	return spd_indicator
end

WT.Gadget.RegisterFactory("Speedometer",
	{
		name = "Speedometer",
		description = "Indicates how fast you're moving.",
		author = "Finney@Deepwood",
		version = "0.1.0",
		iconTexAddon = AddonId,
		iconTexFile = "img/Speed2.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration,
		["SetConfiguration"] = SetConfiguration,
	})


local function OnTick(frameDeltaTime, frameIndex)
	local now = Inspect.Time.Real()
	if now - last_update > updateInterval + .1 then
		for idx, gadget in ipairs(SpeedometerIndicators) do
			gadget.SpdText:SetText("000")
			gadget.SpdText2:SetText("000")
			if showMPH == true then
				gadget.MphText2:SetText("00.0")
				gadget.MphText:SetText("00.0")
			end
			if showRPS == true then
				gadget.RpsText2:SetText("00.0")
				gadget.RpsText:SetText("00.0")
			end
			if showIcon == true then
				for k, v in pairs(gadget.imgSpeedIcon) do v:SetVisible(false) end
				gadget.imgSpeedIcon[1]:SetVisible(true)
			end
		end
		for k,v in pairs(PreviousCoords) do PreviousCoords[k] = nil end
		spd_total_speed = 0
		spd_total_updates = 0
	end
end

table.insert(WT.Event.Tick, { OnTick, AddonId, AddonId .. "_OnTick" })
