--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.10.0
      Project Date (UTC)  : 2013-09-17T18:45:13Z
      File Modified (UTC) : 2013-09-16T14:06:04Z (lifeismystery)
      -----------------------------------------------------------------     
--]]
--for k,v in pairs(WT) do print(tostring(k).."="..tostring(v)) end
local dialog = false
local preview = nil

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

local testCast = 
{
	id = A3C5AEC64D3793518,
	icon = "Data/\\UI\\ability_icons\\soulbind.dds",
	idNew = A3C5AEC64D3793518,
	name= "Soul Recall",
	castingTime = "8.0s",
}
local PHICON = "Data/\\UI\\texture\\global\\placeholder_icon.dds"

local function OnCastName(unitFrame, castname)
	if castname  then
	local unit = unitFrame.Unit
			if unit.castUninterruptible then
				unitFrame.barCast:SetShape(unitFrame.canvasSettings.pathCastbar, unitFrame.canvasSettings.fillCastbarNonInt, unitFrame.canvasSettings.strokeCastbar)
		else
				unitFrame.barCast:SetShape(unitFrame.canvasSettings.pathCastbar, unitFrame.canvasSettings.fillCastbar, unitFrame.canvasSettings.strokeCastbar)
		end
		if unitFrame.showcastName == true then 
		unitFrame.labelCast:SetText(castname) 
		unitFrame.labelCast:SetVisible(true)
		else end
		if unitFrame.showIcon == false then 
		--
		else	
		--local unit = unitFrame.Unit
		if unitFrame.icon then
			local cbd = Inspect.Unit.Castbar(unit.id)
				if cbd then
					if cbd.abilityNew then
						local ad = Inspect.Ability.New.Detail(cbd.abilityNew)
						if ad and ad.icon then
							if ad.icon == PHICON then
							unitFrame.icon:SetVisible(false)
							else
							unitFrame.icon:SetTexture("Rift", ad.icon)
							unitFrame.icon:SetVisible(true)
							end
						else
							unitFrame.icon:SetVisible(false)
						end
					else
						unitFrame.icon:SetVisible(false)
					end
				else
					WT.UnitDatabase.Casting[unit.id] = nil
					WT.Units[unit.id].castName = nil
				end
		end
		end
	else
		unitFrame.icon:SetVisible(false)
		unitFrame.barCast:SetVisible(false)
		--unitFrame.labelTime:SetVisible(false)
		unitFrame.labelCast:SetVisible(false)
		unitFrame.Backdrop:SetVisible(false)
	end
end
local function OncastTime(unitFrame, castTime)
	if castTime then		
	if unitFrame.TimeFormat == "castTime" then
		unitFrame.labelTime:SetText(castTime)
	elseif unitFrame.TimeFormat == "none" then
		unitFrame.labelTime:SetText("")
	end
	end
end

local function OncastTime_s(unitFrame, castTime_s)
	if castTime_s then		
	if unitFrame.TimeFormat == "castTime_s" then
		unitFrame.labelTime:SetText(castTime_s)
	elseif unitFrame.TimeFormat == "none" then
		unitFrame.labelTime:SetText("")
	end
	end
end

local function OncastTimeShot(unitFrame, castTimeShot)
	if castTimeShot then		
	if unitFrame.TimeFormat == "castTimeShot" then
		unitFrame.labelTime:SetText(castTimeShot)
	elseif unitFrame.TimeFormat == "none" then
		unitFrame.labelTime:SetText("")
	end
	end
end

local function OncastTimeShot_s(unitFrame, castTimeShot_s)
	if castTimeShot_s then		
	if unitFrame.TimeFormat == "castTimeShot_s" then
		unitFrame.labelTime:SetText(castTimeShot_s)
	elseif unitFrame.TimeFormat == "none" then
		unitFrame.labelTime:SetText("")
	end
	end
end

local function OncastPercent(unitFrame, castPercent)
	if castPercent then
		if unitFrame.barCast and unitFrame.Backdrop then	
			local delta = (100 - castPercent) / 100 * unitFrame.realWidth
			if unitFrame.insertCast == false then delta = -delta end
			unitFrame.barCast:SetPoint("TOPLEFT", unitFrame.barMask, "TOPLEFT", delta, 0)
			unitFrame.barCast:SetPoint("BOTTOMRIGHT", unitFrame.barMask, "BOTTOMRIGHT", delta, 0)

			unitFrame.barCast:SetVisible(true)
			unitFrame.Backdrop:SetVisible(true)
		end
	else
		if unitFrame.barCast and unitFrame.Backdrop then
			unitFrame.barCast:SetVisible(false)
			unitFrame.Backdrop:SetVisible(false)
		end
	end	
end

function UpdatePreview(configuration)

	local configuration = data.Castbar_GetConfiguration()
	preview.config = configuration
	configuration.iconPositionX = WT.Preview["CastbarPreview_icon"].config.iconPositionX
	configuration.iconPositionY = WT.Preview["CastbarPreview_icon"].config.iconPositionY
	configuration.namePositionX = WT.Preview["CastbarPreview_name"].config.namePositionX
	configuration.namePositionY = WT.Preview["CastbarPreview_name"].config.namePositionY
	configuration.timePositionX = WT.Preview["CastbarPreview_time"].config.timePositionX
	configuration.timePositionY = WT.Preview["CastbarPreview_time"].config.timePositionY

	preview:SetWidth(350)
	preview:SetHeight(80)

	UpdateSliders ()
	data.LayoutCast(preview.frmCast, configuration)
	data.UpdateCast(preview, preview.frmCast, testCast)
	
	preview.frmCast:SetPoint("CENTER", preview, "CENTER")
end

WT.Control.UpdatePreview_Cast = UpdatePreview

local function GetConfiguration()
	local config = {}
	config.unitSpec = dialog.fields[2].control:GetText()
	config.TimeFormat = dialog.fields[3].control:GetText()
	config.font = dialog.fields[4].control:GetText()
	config.textFontSizeName = dialog.fields[5].control.slider:GetPosition() 
	config.textFontSizeTime = dialog.fields[6].control.slider:GetPosition() 
	config.colorInterrupt = {dialog.fields[7].control:GetColor() } --{0.15000000596046, 0.61000001430511, 1, 1}, 
	config.colorNoInterrupt = {dialog.fields[8].control:GetColor() } --{1, 0.37999999523163, 0.079999998211861, 1}, 
	config.insertCast = dialog.fields[9].control:GetChecked()
	config.TextRight = dialog.fields[10].control:GetChecked() 
	config.Width = dialog.fields[11].control.slider:GetPosition()
	config.Height = dialog.fields[12].control.slider:GetPosition() 
	config.angle = dialog.fields[13].control.slider:GetPosition()  
    config.showIcon = dialog.fields[14].control:GetChecked()
	config.iconSize = dialog.fields[15].control.slider:GetPosition() 
	config.showcastName = dialog.fields[16].control:GetChecked() 
	config.showcastTime = dialog.fields[17].control:GetChecked() 
	config.timePositionX = dialog.fields[18].control.slider:GetPosition() 
	config.timePositionY = dialog.fields[19].control.slider:GetPosition()
	config.namePositionX = dialog.fields[20].control.slider:GetPosition() 
	config.namePositionY = dialog.fields[21].control.slider:GetPosition() 
	config.iconPositionX = dialog.fields[22].control.slider:GetPosition()  
	config.iconPositionY = dialog.fields[23].control.slider:GetPosition()   
	return config
end
data.Castbar_GetConfiguration = GetConfiguration

local function SetConfiguration(config)
	dialog:SetValues(config)
	WT.Preview["CastbarPreview"].config = config
	WT.Preview["CastbarPreview_icon"].config = config
	WT.Preview["CastbarPreview_time"].config = config
	WT.Preview["CastbarPreview_name"].config = config
	UpdatePreview()
end
	
local function ConfigDialog(container)

	if WT.Preview["CastbarPreview"] == nil then WT.Preview["CastbarPreview"] = {} end
	local lMedia = Library.Media.FindMedia("bar")
	local listMedia = {}
	for mediaId, media in pairs(lMedia) do
		table.insert(listMedia, { ["text"]=mediaId, ["value"]=mediaId })
	end
	
	local lfont = Library.Media.GetFontIds("font")
	local listfont = {}
	local listfont = {}
	for v, k in pairs(lfont) do
		table.insert(listfont, { value=k })
	end

	dialog = WT.Dialog(container)
		:Label("The cast bar gadget shows a cast bar for the unit selected.") --1
		:Combobox("unitSpec", "Unit to track", "player",
			{
				{text="Player", value="player"},
				{text="Target", value="player.target"},
				{text="Target's Target", value="player.target.target"},
				{text="Focus", value="focus"},
				{text="Focus's Target", value="focus.target"},
				{text="Pet", value="player.pet"},
			}, false)	                                                 --2				
	    :Combobox("TimeFormat", "Cast Time Format", "castTimeShot",
			{
				{text="1,3/3s", value="castTime"},
				{text="1,3/3", value="castTime_s"},
				{text="1.3", value="castTimeShot"},
				{text="1.3s", value="castTimeShot_s"},
			}, false)			                                       --3
		:Select("font", "Font", "#Default", lfont, true, onchange)      --4
		:SliderRange("textFontSizeName", "Font Size CastName", 6, 50, 14, true)  --5
		:SliderRange("textFontSizeTime", "Font Size CastTime", 6, 50, 20, true)  --6
		:ColorPicker("colorInterrupt", "Interruptible color", 0.15, 0.61, 1.0, 1.0 )   --7
		:ColorPicker("colorNoInterrupt", "Non-Interruptible color", 1.0, 0.38, 0.08, 1.0 )  --8
		:Checkbox("insertCast", "insert Cast", false)   --9 
		:Checkbox("TextRight", "Text to Right", false) -- 10
		:SliderRange("Width", "CastBar Width", 150, 400, 250, true) --11
		:SliderRange("Height", "CastBar Height", 5, 50, 10, true)--12
		:SliderRange("angle", "Angle of the cast bar", 0, 180, 0, true)	--13		
		:Checkbox("showIcon", "Show Icon", true)	--14
		:SliderRange("iconSize", "Change Icon Size", 10, 50, 35, true)--15
		:Checkbox("showcastName", "Show cast name", true)--16
		:Checkbox("showcastTime", "Show cast time", true)--17
		:SliderRange("timePositionX", "Change castTime positionX", -2000, 2000, 0, true) --18
		:SliderRange("timePositionY", "Change castTime positionY", -2000, 2000, 15, true)  --19
		:SliderRange("namePositionX", "Change castName positionX", -2000, 2000, 0, true)--20
		:SliderRange("namePositionY", "Change castName positionY", -2000, 2000, -25, true)	--21
		:SliderRange("iconPositionX", "Change Icon positionX", -2000, 3000, -40, true)--22
		:SliderRange("iconPositionY", "Change Icon positionY", -2000, 3000, -15, true)--23
		
		
		dialog.btnUnlockIcon = UI.CreateFrame("Frame", "btnUnlockIcon", container)
		dialog.btnUnlockIcon:SetWidth(120)
		dialog.btnUnlockIcon:SetHeight(25)
		dialog.btnUnlockIcon:SetBackgroundColor(0.2,0.2,0.2,0.4)
		dialog.btnUnlockIcon:SetPoint("TOPLEFT", container, "TOPLEFT", 10, 525)	
			
		dialog.btnUnlockIconTxt = UI.CreateFrame("Text", "txtbtnUnlockIconTxt", dialog.btnUnlockIcon)
		dialog.btnUnlockIconTxt:SetText("Unlock frames")
		dialog.btnUnlockIconTxt:SetFontSize(16)
		dialog.btnUnlockIconTxt:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		dialog.btnUnlockIconTxt:SetFontColor(1,0.97,0.84,1)
		dialog.btnUnlockIconTxt:SetPoint("TOPLEFT", dialog.btnUnlockIcon, "TOPLEFT", 10, 0)
		
		dialog.btnUnlockIcon:EventAttach(Event.UI.Input.Mouse.Cursor.In, function(self, h)
			dialog.btnUnlockIcon:SetBackgroundColor(1,0.97,0.84,0.5)
		end, "Event.UI.Input.Mouse.Cursor.In")
		dialog.btnUnlockIcon:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function(self, h)
			dialog.btnUnlockIcon:SetBackgroundColor(0.2,0.2,0.2,0.4)
		end, "Event.UI.Input.Mouse.Cursor.Out")

		
		dialog.btnUnlockIcon:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self, h)
		if dialog.btnUnlockIconTxt:GetText() == "Lock frames" then
			dialog.btnUnlockIconTxt:SetText("Unlock frames")
			--UpdateSliders()
			WT.Preview.gadgetsLocked_Preview = true
			WT.Preview.ToggleAll()
		else
			dialog.btnUnlockIconTxt:SetText("Lock frames")
			WT.Preview.gadgetsLocked_Preview = false
			WT.Preview.ToggleAll()
		end
	end, "Event.UI.Input.Mouse.Left.Click")
	
	preview = UI.CreateFrame("Frame", "frmCastPreview", container)
	preview:SetPoint("TOPLEFT", container, "TOPRIGHT", 100, 0)
	preview:SetWidth(250)
	preview:SetHeight(200)
	preview:SetLayer(1)
	
	preview.config = GetConfiguration()	
	WT.Preview["CastbarPreview"] = preview

	preview.frmCast = data.ConstructCast(preview, true)
	UpdatePreview()
	

	dialog.fields[5].control.Event.SliderChange = UpdatePreview
	dialog.fields[6].control.Event.SliderChange = UpdatePreview
	dialog.fields[7].control.OnColorChanged = UpdatePreview 
	dialog.fields[8].control.OnColorChanged = UpdatePreview 
	dialog.fields[9].control.Event.CheckboxChange = UpdatePreview
	dialog.fields[10].control.Event.CheckboxChange = UpdatePreview
	dialog.fields[11].control.Event.SliderChange = UpdatePreview
	dialog.fields[12].control.Event.SliderChange = UpdatePreview
	dialog.fields[13].control.Event.SliderChange = UpdatePreview
	dialog.fields[14].control.Event.CheckboxChange = UpdatePreview
	dialog.fields[15].control.Event.SliderChange = UpdatePreview
	dialog.fields[16].control.Event.CheckboxChange = UpdatePreview
	dialog.fields[17].control.Event.CheckboxChange = UpdatePreview
	dialog.fields[18].control.Event.SliderChange = UpdatePreview
	dialog.fields[19].control.Event.SliderChange = UpdatePreview
	dialog.fields[20].control.Event.SliderChange = UpdatePreview
	dialog.fields[21].control.Event.SliderChange = UpdatePreview
	dialog.fields[22].control.Event.SliderChange = UpdatePreview
	dialog.fields[23].control.Event.SliderChange = UpdatePreview
	
	dialog.fields[18]:SetVisible(false)
	dialog.fields[19]:SetVisible(false)
	dialog.fields[20]:SetVisible(false)
	dialog.fields[21]:SetVisible(false)
	dialog.fields[22]:SetVisible(false)	
	dialog.fields[23]:SetVisible(false)
end

function UpdateSliders ()
	
	dialog.fields[5].control.slider:SetPosition(WT.Preview["CastbarPreview"].config.textFontSizeName)
	dialog.fields[6].control.slider:SetPosition(WT.Preview["CastbarPreview"].config.textFontSizeTime)
	dialog.fields[9].control:SetChecked(WT.Preview["CastbarPreview"].config.insertCast)
	dialog.fields[10].control:SetChecked(WT.Preview["CastbarPreview"].config.TextRight)
	dialog.fields[11].control.slider:SetPosition(WT.Preview["CastbarPreview"].config.Width)
	dialog.fields[12].control.slider:SetPosition(WT.Preview["CastbarPreview"].config.Height)
	dialog.fields[13].control.slider:SetPosition(WT.Preview["CastbarPreview"].config.angle)
	dialog.fields[14].control:SetChecked(WT.Preview["CastbarPreview"].config.showIcon)
	dialog.fields[15].control.slider:SetPosition(WT.Preview["CastbarPreview"].config.iconSize)
	dialog.fields[16].control:SetChecked(WT.Preview["CastbarPreview"].config.showcastName)
	dialog.fields[17].control:SetChecked(WT.Preview["CastbarPreview"].config.showcastTime)
	dialog.fields[18].control.slider:SetPosition(WT.Preview["CastbarPreview"].config.timePositionX)
	dialog.fields[19].control.slider:SetPosition(WT.Preview["CastbarPreview"].config.timePositionY)
	dialog.fields[20].control.slider:SetPosition(WT.Preview["CastbarPreview"].config.namePositionX)
	dialog.fields[21].control.slider:SetPosition(WT.Preview["CastbarPreview"].config.namePositionY)
	dialog.fields[22].control.slider:SetPosition(WT.Preview["CastbarPreview"].config.iconPositionX)
	dialog.fields[23].control.slider:SetPosition(WT.Preview["CastbarPreview"].config.iconPositionY)
	
end
	
local function UpdateCast(config, cast, testCast)
	cast:SetVisible(true)
	cast.id = testCast.id
	cast.icon_testCast = testCast.icon
	cast.idNew = testCast.idNew
	cast.testcastName = testCast.name
	cast.castingTime = testCast.castingTime
	cast.fontEntry = Library.Media.GetFont(config.config.font) 
	cast.TimeFormat = config.config.TimeFormat
	cast.Width = config.config.Width
	cast.Height = config.config.Height
	cast.textFontSizeName = config.config.textFontSizeName
	cast.textFontSizeTime = config.config.textFontSizeTime
	cast.showcastName = config.config.showcastName
	cast.showcastTime = config.config.showcastTime
	cast.showIcon = config.config.showIcon
	cast.colorInterrupt = config.config.colorInterrupt
	cast.colorNoInterrupt = config.config.colorNoInterrupt
	cast.TextRight = config.config.TextRight
	cast.namePositionX = config.config.namePositionX
	cast.namePositionY = config.config.namePositionY
	cast.timePositionX = config.config.timePositionX
	cast.timePositionY = config.config.timePositionY
	cast.iconPositionX = config.config.iconPositionX
	cast.iconPositionY = config.config.iconPositionY
	
	if cast.showIcon == true then
		cast.icon:SetTexture("Rift", cast.icon_testCast)
		cast.icon:SetVisible(true)
	else
		cast.icon:SetVisible(false)
	end
	if cast.showcastName == true then
		cast.labelCast:SetText(cast.testcastName)
		cast.labelCast:SetFontSize(cast.textFontSizeName)
		cast.labelCast:SetFont(cast.fontEntry.addonId, cast.fontEntry.filename)
		cast.labelCast:SetVisible(true)
	else
		cast.labelCast:SetVisible(false)
	end
	if cast.showcastTime == true then
		if cast.TimeFormat == "castTime_s" then
			cast.labelTime:SetText("7.9/8.0")
		elseif	cast.TimeFormat == "castTime" then
			cast.labelTime:SetText("7.9/8.0s")
		elseif	cast.TimeFormat == "castTimeShot" then
			cast.labelTime:SetText("8.0")
		elseif cast.TimeFormat == "castTimeShot_s" then
			cast.labelTime:SetText("8.0s")
		end
		cast.labelTime:SetFontSize(cast.textFontSizeTime)
		cast.labelTime:SetFont(cast.fontEntry.addonId, cast.fontEntry.filename)
		cast.labelTime:SetVisible(true)
	else
		cast.labelTime:SetVisible(false)
	end
	
	cast.labelCast:SetPoint("TOPLEFT", cast.Backdrop, "TOPLEFT", cast.namePositionX, cast.namePositionY)
	
	cast:SetWidth(cast.Width)
	cast:SetHeight(cast.Height)

	
end				
data.UpdateCast = UpdateCast

local function LayoutCast(cast, config)

	config.fontEntry = Library.Media.GetFont(config.font) 
	
	config.canvasSettings = {
		angle = config.angle or 0, -- угол наклона в градусах, 0 - вертикально, 45/135 - по диагонали, допустимые значения 0-180
		castbarIndent = 1, -- размер отступа от бека до бара
		strokeBack = { r = 0, g = 0, b = 0, a = 1, thickness = 1 },
		strokeBack_icon = { r = 0, g = 0, b = 0, a = 1, thickness = 2 },
		fillBack = { type = "solid", r = 0, g = 0, b = 0, a = 0.75 },
		fillBack_icon = { type = "solid", r = 0, g = 0, b = 0, a = 1 },
		strokeCastbar = { r = 0.15, g = 0.61, b = 1, thickness = 0 },
		fillCastbar = { type = "solid", r = config.colorInterrupt[1], g = config.colorInterrupt[2], b = config.colorInterrupt[3], a = config.colorInterrupt[4] },
		fillCastbarNonInt = { type = "solid", r = config.colorNoInterrupt[1], g = config.colorNoInterrupt[2], b = config.colorNoInterrupt[3], a = config.colorNoInterrupt[4] },
	}
	cast:SetWidth(WT.Preview["CastbarPreview"].config.Width)
	cast:SetHeight(WT.Preview["CastbarPreview"].config.Height)

	cast.Backdrop:SetPoint("TOPLEFT", cast, "TOPLEFT")
	cast.Backdrop:SetPoint("BOTTOMRIGHT", cast, "BOTTOMRIGHT")
	cast.Backdrop:SetLayer(1)
	cast.Backdrop:SetVisible(true)

	cast.barMask:SetPoint("TOPLEFT", cast.Backdrop, "TOPLEFT", config.canvasSettings.castbarIndent, config.canvasSettings.castbarIndent)
	cast.barMask:SetPoint("BOTTOMRIGHT", cast.Backdrop, "BOTTOMRIGHT", -config.canvasSettings.castbarIndent, -config.canvasSettings.castbarIndent)
	cast.barMask:SetLayer(2)

	cast.OnResize = function()
		local tg = math.tan(WT.Preview["CastbarPreview"].config.canvasSettings.angle * math.pi / 180)
		local offset = tg * cast:GetHeight() / cast:GetWidth() / 2
		local indentOffset = tg * WT.Preview["CastbarPreview"].config.canvasSettings.castbarIndent / cast:GetWidth()
		cast.realWidth = cast:GetWidth() - math.abs(tg * cast:GetHeight()) - config.canvasSettings.castbarIndent * 2

		config.canvasSettings.path = { 
			{ xProportional = math.abs(offset) - offset, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset) - offset, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset) + offset, yProportional = 1 },
			{ xProportional = math.abs(offset) + offset, yProportional = 1 }
		}
		config.canvasSettings.pathCastbar = { 
			{ xProportional = math.abs(offset) - offset + indentOffset, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset) - offset + indentOffset, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset) + offset - indentOffset, yProportional = 1 },
			{ xProportional = math.abs(offset) + offset - indentOffset, yProportional = 1 }
		}

		cast.Backdrop:SetShape(config.canvasSettings.path, config.canvasSettings.fillBack, config.canvasSettings.strokeBack)
		cast.barMask:SetShape(config.canvasSettings.pathCastbar)
		cast.barCast:SetShape(config.canvasSettings.pathCastbar, config.canvasSettings.fillCastbar, config.canvasSettings.strokeCastbar)
	end

	cast.OnResize()
	
	cast.barCast:SetPoint("TOPLEFT", cast.barMask, "TOPLEFT")
	cast.barCast:SetPoint("BOTTOMRIGHT", cast.barMask, "BOTTOMRIGHT")
	cast.barCast:SetLayer(3)
	
	cast.icon:SetLayer(4)
	cast.icon:SetWidth(config.iconSize)
	cast.icon:SetHeight(config.iconSize)
	
	cast.iconBackdrop:SetPoint("TOPLEFT", cast.icon, "TOPLEFT", -1, -1)
	cast.iconBackdrop:SetPoint("BOTTOMRIGHT", cast.icon, "BOTTOMRIGHT", -0.5, -0.5)
	cast.iconBackdrop:SetLayer(4)
	config.canvasSettings.path_iconBackdrop = { 
			{ xProportional = 0, yProportional = 0 },
			{ xProportional = 1, yProportional = 0 },
			{ xProportional = 1, yProportional = 1 },
			{ xProportional = 0 ,yProportional = 1 },
			{ xProportional = 0 ,yProportional = 0 }}
	cast.iconBackdrop:SetShape(config.canvasSettings.path_iconBackdrop, config.canvasSettings.fillBack_icon, config.canvasSettings.strokeBack_icon)

	cast.labelCast:SetLayer(4)
	cast.labelCast:SetText("")
	cast.labelCast:SetEffectGlow({ strength = 3 })
	cast.labelCast:SetFontSize(config.textFontSizeName or 14)
	cast.labelCast:SetFont(config.fontEntry.addonId, config.fontEntry.filename)

	cast.labelTime:SetLayer(4)
	cast.labelTime:SetText("")
	cast.labelTime:SetEffectGlow({ strength = 3 })
	cast.labelTime:SetFontSize(config.textFontSizeTime or 20)
	cast.labelTime:SetFont(config.fontEntry.addonId, config.fontEntry.filename)
	
	cast.icon:SetPoint("TOPLEFT", cast.Backdrop, "TOPLEFT",  config.iconPositionX, config.iconPositionY)
	cast.labelCast:SetPoint("TOPLEFT", cast.Backdrop, "TOPLEFT", config.namePositionX, config.namePositionY)
	cast.labelTime:SetPoint("TOPLEFT", cast.Backdrop, "TOPLEFT", config.timePositionX, config.timePositionY)

	--[[if cast.TextRight == true then 
	cast.labelCast:SetPoint("TOPRIGHT", cast.Backdrop, "TOPLEFT", config.namePositionX, config.namePositionY)
	--cast.labelTime:SetPoint("TOPRIGHT", cast.Backdrop, "TOPLEFT", cast.timePositionX, cast.timePositionY)
	else
	cast.labelCast:SetPoint("TOPLEFT", cast.Backdrop, "TOPLEFT", config.namePositionX, config.namePositionY)
	--cast.labelTime:SetPoint("TOPLEFT", cast.Backdrop, "TOPLEFT", cast.timePositionX, cast.timePositionY)
	end
	]]

	WT.Preview["CastbarPreview_icon"] = cast.icon
	WT.Previews["CastbarPreview_icon"] = WT.Preview["CastbarPreview_icon"]
	WT.Preview["CastbarPreview_icon"].Parent = cast.Backdrop
	WT.Preview["CastbarPreview_icon"].config = GetConfiguration()
	
	WT.Preview["CastbarPreview_name"] = cast.labelCast
	WT.Previews["CastbarPreview_name"] = WT.Preview["CastbarPreview_name"]
	WT.Preview["CastbarPreview_name"].Parent = cast.Backdrop
	WT.Preview["CastbarPreview_name"].config = GetConfiguration()
	
	WT.Preview["CastbarPreview_time"] = cast.labelTime
	WT.Previews["CastbarPreview_time"] = WT.Preview["CastbarPreview_time"]
	WT.Preview["CastbarPreview_time"].Parent = cast.Backdrop
	WT.Preview["CastbarPreview_time"].config = GetConfiguration()
	
	WT.Preview.AttachHandle_Preview("CastbarPreview_icon", cast.icon, {})	
	WT.Preview.AttachHandle_Preview("CastbarPreview_name", cast.labelCast, {})	
	WT.Preview.AttachHandle_Preview("CastbarPreview_time", cast.labelTime, {})
	
end

local function ConstructCast(castBar, isPreview)

	local cast = UI.CreateFrame("Frame", "castBar", castBar)
	cast.Backdrop = UI.CreateFrame("Canvas", "Backdrop", cast)
	cast.barMask = UI.CreateFrame("Mask", "barMask", cast.Backdrop)
	cast.barCast = UI.CreateFrame("Canvas", "barCast", cast.barMask)
	cast.icon = UI.CreateFrame("Texture", "icon", cast.Backdrop)
	cast.iconBackdrop = UI.CreateFrame("Canvas", "iconBackdrop", cast.icon)
	cast.labelCast = UI.CreateFrame("Text", "labelCast", cast.Backdrop)
	cast.labelTime = UI.CreateFrame("Text", "labelTime", cast.Backdrop)
	LayoutCast(cast, castBar.config)
	return cast
end

data.ConstructCast = ConstructCast
data.LayoutCast = LayoutCast

local function Create(configuration)

	local castBar = WT.UnitFrame:Create(configuration.unitSpec)
	castBar.fontEntry = Library.Media.GetFont(configuration.font)-- or "#Rift"
	castBar.textFontSizeName = configuration.textFontSizeName --or 14
	castBar.textFontSizeTime = configuration.textfontSizeTime --or 20
	castBar.colorInterrupt = configuration.colorInterrupt --or {0.15, 0.61, 1.0, 1.0}
	castBar.colorNoInterrupt = configuration.colorNoInterrupt --or {1.0, 0.38, 0.08, 1.0 }
	castBar.showIcon = configuration.showIcon --or true
	castBar.iconPositionX = configuration.iconPositionX --or -40
	castBar.iconPositionY = configuration.iconPositionY --or -15
	castBar.showcastName = configuration.showcastName --or true	
	castBar.namePositionX = configuration.namePositionX --or 0
	castBar.namePositionY = configuration.namePositionY --or 0
	castBar.showcastTime = configuration.showcastTime --or true
	castBar.timePositionX = configuration.timePositionX --or 0
	castBar.timePositionY = configuration.timePositionY --or 0
	castBar.iconSize = configuration.iconSize --or 35
	castBar.TimeFormat = configuration.TimeFormat
	castBar.Width = configuration.Width --or 250
	castBar.Height = configuration.Height --or 10
	castBar.insertCast = configuration.insertCast --or false
	castBar.TextRight = configuration.TextRight --or false
	
	castBar.canvasSettings = {
		angle = configuration.angle or 0, -- угол наклона в градусах, 0 - вертикально, 45/135 - по диагонали, допустимые значения 0-180
		castbarIndent = 1, -- размер отступа от бека до бара
		strokeBack = { r = 0, g = 0, b = 0, a = 1, thickness = 1 },
		strokeBack_icon = { r = 0, g = 0, b = 0, a = 1, thickness = 2 },
		fillBack = { type = "solid", r = 0, g = 0, b = 0, a = 0.75 },
		fillBack_icon = { type = "solid", r = 0, g = 0, b = 0, a = 1 },
		strokeCastbar = { r = 0.15, g = 0.61, b = 1, thickness = 0 },
		fillCastbar = { type = "solid", r = castBar.colorInterrupt[1], g = castBar.colorInterrupt[2], b = castBar.colorInterrupt[3], a = castBar.colorInterrupt[4] },
		fillCastbarNonInt = { type = "solid", r = castBar.colorNoInterrupt[1], g = castBar.colorNoInterrupt[2], b = castBar.colorNoInterrupt[3], a = castBar.colorNoInterrupt[4] },
	}
	
	castBar:SetWidth(castBar.Width)
	castBar:SetHeight(castBar.Height)
	
	castBar.Backdrop = UI.CreateFrame("Canvas", "Backdrop", castBar)
	castBar.Backdrop:SetPoint("TOPLEFT", castBar, "TOPLEFT", 0, 0)
	castBar.Backdrop:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMRIGHT", 0, 0)
	castBar.Backdrop:SetLayer(1)
	castBar.Backdrop:SetVisible(true)

	castBar.barMask = UI.CreateFrame("Mask", "barMask", castBar.Backdrop)
	castBar.barMask:SetPoint("TOPLEFT", castBar.Backdrop, "TOPLEFT", castBar.canvasSettings.castbarIndent, castBar.canvasSettings.castbarIndent)
	castBar.barMask:SetPoint("BOTTOMRIGHT", castBar.Backdrop, "BOTTOMRIGHT", -castBar.canvasSettings.castbarIndent, -castBar.canvasSettings.castbarIndent)
	castBar.barMask:SetLayer(3)

	castBar.barCast = UI.CreateFrame("Canvas", "barCast", castBar.barMask)
	castBar.barCast:SetPoint("TOPLEFT", castBar.barMask, "TOPLEFT")
	castBar.barCast:SetPoint("BOTTOMRIGHT", castBar.barMask, "BOTTOMRIGHT")
	castBar.barCast:SetLayer(3)

	castBar.OnResize = function()
		local tg = math.tan(castBar.canvasSettings.angle * math.pi / 180)
		local offset = tg * castBar:GetHeight() / castBar:GetWidth() / 2
		local indentOffset = tg * castBar.canvasSettings.castbarIndent / castBar:GetWidth()
		castBar.realWidth = castBar:GetWidth() - math.abs(tg * castBar:GetHeight()) - castBar.canvasSettings.castbarIndent * 2

		castBar.canvasSettings.path = { 
			{ xProportional = math.abs(offset) - offset, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset) - offset, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset) + offset, yProportional = 1 },
			{ xProportional = math.abs(offset) + offset, yProportional = 1 }
		}
		castBar.canvasSettings.pathCastbar = { 
			{ xProportional = math.abs(offset) - offset + indentOffset, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset) - offset + indentOffset, yProportional = 0 },
			{ xProportional = 1 - math.abs(offset) + offset - indentOffset, yProportional = 1 },
			{ xProportional = math.abs(offset) + offset - indentOffset, yProportional = 1 }
		}

		castBar.Backdrop:SetShape(castBar.canvasSettings.path, castBar.canvasSettings.fillBack, castBar.canvasSettings.strokeBack)
		castBar.barMask:SetShape(castBar.canvasSettings.pathCastbar)
		castBar.barCast:SetShape(castBar.canvasSettings.pathCastbar, castBar.canvasSettings.fillCastbar, castBar.canvasSettings.strokeCastbar)
	end

	castBar.OnResize()

	castBar.icon = UI.CreateFrame("Texture", "icon", castBar)
	castBar.icon:SetLayer(5)
	castBar.icon:SetAlpha(1)
	castBar.icon:SetWidth(castBar.iconSize)
	castBar.icon:SetHeight(castBar.iconSize)
	
	castBar.iconBackdrop = UI.CreateFrame("Canvas", "iconBackdrop", castBar.icon)
	castBar.iconBackdrop:SetPoint("TOPLEFT", castBar.icon, "TOPLEFT", -1, -1)
	castBar.iconBackdrop:SetPoint("BOTTOMRIGHT", castBar.icon, "BOTTOMRIGHT", -0.5, -0.5)
	castBar.iconBackdrop:SetLayer(4)
	castBar.canvasSettings.path_iconBackdrop = { 
			{ xProportional = 0, yProportional = 0 },
			{ xProportional = 1, yProportional = 0 },
			{ xProportional = 1, yProportional = 1 },
			{ xProportional = 0 ,yProportional = 1 },
			{ xProportional = 0 ,yProportional = 0 }}
	castBar.iconBackdrop:SetShape(castBar.canvasSettings.path_iconBackdrop, castBar.canvasSettings.fillBack_icon, castBar.canvasSettings.strokeBack_icon)

	castBar.labelCast = UI.CreateFrame("Text", "labelCast", castBar.Backdrop)
	castBar.labelCast:SetLayer(5)
	castBar.labelCast:SetText("")
	castBar.labelCast:SetEffectGlow({ strength = 3 })
	castBar.labelCast:SetFontSize(castBar.textFontSizeName or 14)
	castBar.labelCast:SetFont(castBar.fontEntry.addonId, castBar.fontEntry.filename)

	castBar.labelTime = UI.CreateFrame("Text", "labelTime", castBar.Backdrop)
	castBar.labelTime:SetLayer(5)
	castBar.labelTime:SetText("")
	castBar.labelTime:SetEffectGlow({ strength = 3 })
	castBar.labelTime:SetFontSize(castBar.textFontSizeTime or 20)
	castBar.labelTime:SetFont(castBar.fontEntry.addonId, castBar.fontEntry.filename)

	castBar.icon:SetPoint("TOPLEFT", castBar.Backdrop, "TOPLEFT", castBar.iconPositionX, castBar.iconPositionY)

	if castBar.TextRight == true then 
	castBar.labelCast:SetPoint("TOPRIGHT", castBar.Backdrop, "TOPLEFT", castBar.namePositionX, castBar.namePositionY)
	castBar.labelTime:SetPoint("TOPRIGHT", castBar.Backdrop, "TOPLEFT", castBar.timePositionX, castBar.timePositionY)
	else
	castBar.labelCast:SetPoint("TOPLEFT", castBar.Backdrop, "TOPLEFT", castBar.namePositionX, castBar.namePositionY)
	castBar.labelTime:SetPoint("TOPLEFT", castBar.Backdrop, "TOPLEFT", castBar.timePositionX, castBar.timePositionY)
	end

	if castBar.showIcon == false and castBar.showcastName == false then 
	--
	else
		castBar:CreateBinding("castName", castBar, OnCastName, nil) 
	end
	if castBar.showcastTime == false then 
	--
	else
	castBar:CreateBinding("castTime", castBar, OncastTime, nil)
	castBar:CreateBinding("castTime_s", castBar, OncastTime_s, nil)
	castBar:CreateBinding("castTimeShot", castBar, OncastTimeShot, nil)
	castBar:CreateBinding("castTimeShot_s", castBar, OncastTimeShot_s, nil)
	end


	castBar:CreateBinding("castPercent", castBar, OncastPercent, nil)

	castBar.Backdrop:SetVisible(false)
	castBar.barCast:SetVisible(false)
	castBar.icon:SetVisible(false)
	
	return castBar, { resizable = { 200, 8, 1000, 100 } }
end


local function Reconfigure(config)

	assert(config.id, "No id provided in reconfiguration details")
	
	local gadgetConfig = wtxGadgets[config.id]
	local gadget = WT.Gadgets[config.id]
	
	assert(gadget, "Gadget id does not exist in WT.Gadgets")
	assert(gadgetConfig, "Gadget id does not exist in wtxGadgets")
	assert(gadgetConfig.type == "CastbarPresets", "Reconfigure Gadget is not a CastbarPresets")
	
	-- Detect changes to config and apply them to the gadget
	
	local requireRecreate = false
	
	if gadgetConfig.unitSpec ~= config.unitSpec then
		gadgetConfig.unitSpec = config.unitSpec
		requireRecreate = true
	end

	if gadgetConfig.angle ~= config.angle then
		gadgetConfig.angle = config.angle
		requireRecreate = true
	end
	if gadgetConfig.font ~= config.font then
		gadgetConfig.font = config.font
		gadget.font = config.font
		requireRecreate = true
	end
	
	if gadgetConfig.TextRight ~= config.TextRight then
		gadgetConfig.TextRight = config.TextRight
		gadget.TextRight = config.TextRight
		requireRecreate = true
	end
	
	if gadgetConfig.TimeFormat ~= config.TimeFormat then
		gadgetConfig.TimeFormat = config.TimeFormat
		requireRecreate = true
	end
		
	if gadgetConfig.textFontSizeName ~= config.textFontSizeName then
		gadgetConfig.textFontSizeName = config.textFontSizeName
		gadget.textFontSize = config.textFontSizeName
		requireRecreate = true
	end
	
	if gadgetConfig.textfontSizeTime ~= config.textfontSizeTime then
		gadgetConfig.textfontSizeTime = config.textfontSizeTime
		gadget.textfontSizeTime = config.textfontSizeTime
		requireRecreate = true
	end
	
	if gadgetConfig.colorInterrupt ~= config.colorInterrupt then
		gadgetConfig.colorInterrupt = config.colorInterrupt
		gadget.colorInterrupt = config.colorInterrupt
		requireRecreate = true
	end
	
	if gadgetConfig.colorNoInterrupt ~= config.colorNoInterrupt then
		gadgetConfig.colorNoInterrupt = config.colorNoInterrupt
		gadget.colorNoInterrupt = config.colorNoInterrupt
		requireRecreate = true
	end
	
	if gadgetConfig.showIcon ~= config.showIcon then
		gadgetConfig.showIcon = config.showIcon
		gadget.showIcon = config.showIcon
		requireRecreate = true
	end

	if gadgetConfig.iconSize ~= config.iconSize then
		gadgetConfig.iconSize = config.iconSize
		gadget.iconSize = config.iconSize
		requireRecreate = true
	end
	
	if gadgetConfig.iconPositionX ~= config.iconPositionX then
		gadgetConfig.iconPositionX = config.iconPositionX
		gadget.iconPositionX = config.iconPositionX
		requireRecreate = true
	end
		
	if gadgetConfig.iconPositionY ~= config.iconPositionY then
		gadgetConfig.iconPositionY = config.iconPositionY
		gadget.iconPositionY = config.iconPositionY
		requireRecreate = true
	end
	
	if gadgetConfig.showcastName ~= config.showcastName then
		gadgetConfig.showcastName = config.showcastName
		gadget.showcastName = config.showcastName
		requireRecreate = true
	end
	
	if gadgetConfig.namePositionX ~= config.namePositionX then
		gadgetConfig.namePositionX = config.namePositionX
		gadget.namePositionX = config.namePositionX
		requireRecreate = true
	end
	
	if gadgetConfig.namePositionY ~= config.namePositionY then
		gadgetConfig.namePositionY = config.namePositionY
		gadget.namePositionY = config.namePositionY
		requireRecreate = true
	end
	
	if gadgetConfig.showcastTime ~= config.showcastTime then
		gadgetConfig.showcastTime = config.showcastTime
		gadget.showcastTime = config.showcastTime
		requireRecreate = true
	end
	
	if gadgetConfig.timePositionX ~= config.timePositionX then
		gadgetConfig.timePositionX = config.timePositionX
		gadget.timePositionX = config.timePositionX
		requireRecreate = true
	end
		
	if gadgetConfig.timePositionY ~= config.timePositionY then
		gadgetConfig.timePositionY = config.timePositionY
		gadget.timePositionY = config.timePositionY
		requireRecreate = true
	end		
	if requireRecreate then
		WT.Gadget.Delete(gadgetConfig.id)
		WT.Gadget.Create(gadgetConfig)
	end		
end
	
WT.Gadget.RegisterFactory("CastbarPresets",
	{
		name="Castbar Presets",
		description="Castbar Presets",
		author="Lifeismystery, Fallenangel",
		version="1.1.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtCastBar.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
		["Reconfigure"] = Reconfigure,
	})