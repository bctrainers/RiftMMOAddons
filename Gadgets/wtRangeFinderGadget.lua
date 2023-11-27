--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.5.91
      Project Date (UTC)  : 2014-01-03T16:42:26Z
      File Modified (UTC) : 2013-10-06T09:26:25Z (lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


-- wtRangeFinder creates a simple Range to Target UnitFrame

local function OnNameChange(rangeFinder, name)
	if not name then
		rangeFinder.txtRange:SetVisible(false)
		rangeFinder.txtName:SetVisible(false)
		if rangeFinder.hideWhenNoTarget then
			rangeFinder.background:SetVisible(false)
		end
	else
		rangeFinder.txtRange:SetVisible(true)
		rangeFinder.txtName:SetVisible(true)
		rangeFinder.background:SetVisible(true)
		local nm = name:upper()
		if nm:len() > 25 then nm = nm:sub(1, 25) end
		rangeFinder.txtName:SetText(nm)
	end
end


local function OnRangeChange(rangeFinder, range)
	if range then
		rangeFinder.txtRange:SetLabelText(string.format("%.01f", range) .. "m")
	else
		rangeFinder.txtRange:SetLabelText(" ")
	end
end

local function OnRangeCenterChange(rangeFinder, rangeCenter)
	if rangeCenter then
		rangeFinder.txtRange:SetLabelText(string.format("%.01f", rangeCenter) .. "m")
	else
		rangeFinder.txtRange:SetLabelText(" ")
	end
end

local function OnSmartRangeChange(rangeFinder, range)
    if range then
        if range <= 2.9 then
        rangeFinder.txtRange:SetLabelText("MELEE ".." "..string.format("%.01f", range) .. "m")
        elseif range <= 20 then
        rangeFinder.txtRange:SetLabelText("RUPT".." "..string.format("%.01f", range) .. "m")
        elseif range <= 28 then
        rangeFinder.txtRange:SetLabelText("AREA ".." "..string.format("%.01f", range) .. "m")
        elseif range <= 30 then
        rangeFinder.txtRange:SetLabelText("RANGED ".." "..string.format("%.01f", range) .. "m")
        elseif range <= 35 then
        rangeFinder.txtRange:SetLabelText("MAX ".." "..string.format("%.01f", range) .. "m")
        else            
        rangeFinder.txtRange:SetLabelText(string.format("%.01f", range) .. "m")
        end
    else
        rangeFinder.txtRange:SetLabelText(" ")
    end
end

local function OnSmartRangeCenterChange(rangeFinder, rangeCenter)
    if rangeCenter then
        if rangeCenter <= 2.9 then
        rangeFinder.txtRange:SetLabelText("MELEE ".." "..string.format("%.01f", rangeCenter) .. "m")
        elseif rangeCenter <= 20 then 
        rangeFinder.txtRange:SetLabelText("RUPT ".." "..string.format("%.01f", rangeCenter) .. "m")
        elseif rangeCenter <= 28 then
        rangeFinder.txtRange:SetLabelText("AREA ".." "..string.format("%.01f", rangeCenter) .. "m")
        elseif rangeCenter <= 30 then
        rangeFinder.txtRange:SetLabelText("RANGED ".." "..string.format("%.01f", rangeCenter) .. "m")
        elseif rangeCenter <= 35 then
        rangeFinder.txtRange:SetLabelText("MAX ".." "..string.format("%.01f", rangeCenter) .. "m")
        else            
        rangeFinder.txtRange:SetLabelText(string.format("%.01f", rangeCenter) .. "m")
        end
    else
        rangeFinder.txtRange:SetLabelText(" ")
    end
end

local function Create(configuration)

	local rfHeight = 70

	local unitSpec = configuration.unitSpec or "player.target"
	
	
	local rangeFinder = WT.UnitFrame:Create(unitSpec)
	rangeFinder:SetWidth(150)
	rangeFinder:SetLayer(100)

	
	local rfBackground = UI.CreateFrame("Frame", "rfBackground", rangeFinder)
	rfBackground:SetAllPoints(rangeFinder)
	if configuration.showBackground then
		rfBackground:SetBackgroundColor(0,0,0,0.4)
	end
	
	rangeFinder.font = Library.Media.GetFont(configuration.font)
	rangeFinder.textFontSize = configuration.fontSize
	rangeFinder.textfontSizeRange = configuration.fontSizeRange
	
	local fontEntry = rangeFinder.font or Library.Media.GetFont("#Default")
	
	rangeFinder.background = rfBackground

	local txtHeading = UI.CreateFrame("Text", WT.UniqueName("RangeFinder"), rfBackground)


	local desc = ""

	if unitSpec == "player.target" then
		desc = "TARGET"
	elseif unitSpec == "player.target.target" then
		desc = "TGT OF TARGET"
	elseif unitSpec == "focus" then
		desc = "FOCUS"
	elseif unitSpec == "focus.target" then
		desc = "TGT OF FOCUS"
	elseif unitSpec == "player.pet" then
		desc = "PET"
	elseif unitSpec == "player.pet.target" then
		desc = "TGT OF PET"
	else
		desc = "UNIT"
	end

	txtHeading:SetText("RANGE TO " .. desc)

	txtHeading:SetPoint("TOPCENTER", rangeFinder, "TOPCENTER", 0, 6)
	txtHeading:SetFontSize(configuration.fontSize or 14)
	txtHeading:SetFont(fontEntry.addonId, fontEntry.filename)
	txtHeading:SetFontColor(0.6, 1.0, 0.6, 1.0)
		
	local txtRange = rangeFinder:CreateElement({
		id="txtRange", type="Label", parent=rfBackground, layer=20,
		attach = {{ point="TOPCENTER", element=txtHeading, targetPoint="BOTTOMCENTER", offsetX=0, offsetY=-5 }},
		visibilityBinding="name", text="--", default="",  outline=true, fontSize=configuration.fontSizeRange or 24, font = configuration.font or "#Default",
		color={ r=0.6, g=1.0, b=0.6, a=1.0 },
	});

	local txtName = UI.CreateFrame("Text", WT.UniqueName("RangeFinder"), rfBackground)
	txtName:SetText("")
	txtName:SetPoint("TOPCENTER", txtRange, "BOTTOMCENTER", 0, -5)
	txtName:SetFontSize(configuration.fontSize or 14)
	txtName:SetFont(fontEntry.addonId, fontEntry.filename)
	txtName:SetFontColor(0.6, 1.0, 0.6, 1.0)
	rangeFinder.txtName = txtName

	if not configuration.showTargetName then
		txtName:SetHeight(0) 
		rfHeight = rfHeight - 17
	end

	if not configuration.showTitle then
		txtHeading:SetHeight(0) 
		rfHeight = rfHeight - 17
	end
	
	if not configuration.changefontColor then
         txtRange:SetFontColor(0.6, 1.0, 0.6, 1.0)
		 else
		 local fontColor = configuration.fontColor 
		 txtRange:SetFontColor(fontColor[1],fontColor[2],fontColor[3],fontColor[4])
	end
	
	rangeFinder.hideWhenNoTarget = configuration.hideWhenNoTarget 
	rangeFinder:SetHeight(rfHeight)
	rangeFinder.txtRange = txtRange
	
	rangeFinder:CreateBinding("name", rangeFinder, OnNameChange, nil)
	if not configuration.showRangeCenter then
		if not configuration.rangeSmartText then
			rangeFinder:CreateBinding("range", rangeFinder, OnRangeChange, nil)
		else
			rangeFinder:CreateBinding("range", rangeFinder, OnSmartRangeChange, nil)
		end
	elseif configuration.showRangeCenter == true then
		if configuration.rangeSmartText == true then
			rangeFinder:CreateBinding("rangeCenter", rangeFinder, OnRangeCenterChange, nil)
		else
			rangeFinder:CreateBinding("rangeCenter", rangeFinder, OnSmartRangeCenterChange, nil)
		end
	end
	
	return rangeFinder, { resizable={50, 25, 250, 70} }
end


local dialog = false

local function ConfigDialog(container)	

	local lfont = Library.Media.GetFontIds("font")
	local listfont = {}
	for v, k in pairs(lfont) do
		table.insert(listfont, { value=k })
	end
	
	dialog = WT.Dialog(container)
		:Label("The Range Finder dispays the distance, in meters, between you and your target. It reports the distance from the center of your character to the center of the target. An option will be added in future to take the radius of the characters into account.")
		:Checkbox("showRangeCenter", "Range to center of target/focus", false)
		:Title("")
		:Title("")
		:Checkbox("showTitle", TXT.ShowTitle, false)
		:Checkbox("showTargetName", TXT.ShowTargetName, true)
		:Checkbox("hideWhenNoTarget", TXT.HideWhenNoTarget, false)
		:Title("")
		:Title("")
		:Checkbox("showBackground", TXT.ShowBackground, false)
		:Combobox("unitSpec", TXT.UnitToTrack, "player.target",
			{
				{text="Target", value="player.target"},
				{text="Target's Target", value="player.target.target"},
				{text="Focus", value="focus"},
				{text="Focus's Target", value="focus.target"},
				{text="Pet", value="player.pet"},
			}, false) 
		--:Checkbox("smallFont", TXT.smallFont, false)
		:Checkbox("changefontColor", "Change range font color", false)	
		:ColorPicker("fontColor", "Range font color", 0.6, 1.0, 0.6, 1.0)	
		:Select("font", "Font", "#Default", lfont, true)
		:Slider("fontSize", "Font Size", 14, true)
		:Slider("fontSizeRange", "Font Size for Range text", 18, true)
		:Checkbox("rangeSmartText", "Snow range Smart Text", false)
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end


WT.Gadget.RegisterFactory("RangeFinder",
	{
		name=TXT.gadgetRangeFinder_name,
		description=TXT.gadgetRangeFinder_desc,
		author="Wildtide",
		version="1.0.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtRangeFinder.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})

