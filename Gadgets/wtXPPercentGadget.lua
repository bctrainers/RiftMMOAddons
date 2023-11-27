--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.8.2
      Project Date (UTC)  : 2015-04-09T12:07:39Z
      File Modified (UTC) : 2013-09-14T08:23:02Z (Adelea)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


-- wtXPPercent Gadget - a simple % display of current XP

local gadgetIndex = 0
local xpGadgets = {}


local function OnExperience(hEvent, accum, rested, needed)

	if not accum then return end
	if not needed then return end

	local percent = (accum / needed) * 100
	local percentString = string.format("%i", math.floor(percent)) .. "%"
	for idx, gadget in ipairs(xpGadgets) do
		gadget:SetText(percentString)
		gadget.detail:SetText(WT.Utility.NumberDesc(accum) .. "/" .. WT.Utility.NumberDesc(needed))
	end
end


local function Create(configuration)

	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("wtXP"), WT.Context)
	wrapper:SetWidth(150)
	wrapper:SetHeight(64)
	if configuration.showBackground == nil or configuration.showBackground == true then
		wrapper:SetBackgroundColor(0,0,0,0.4)
	else 
		wrapper:SetBackgroundColor(0,0,0,0)
	end

	local xpHeading = UI.CreateFrame("Text", WT.UniqueName("wtXP"), wrapper)
	xpHeading:SetText("EXPERIENCE")
	if configuration.showTextEXPERIENCE == true or configuration.showTextEXPERIENCE == nil then	
		xpHeading:SetFontSize(configuration.fontSize or 10)
	else	
		xpHeading:SetFontSize(0)
	end 

	local xpFrame = UI.CreateFrame("Text", WT.UniqueName("wtXP"), wrapper)
	xpFrame:SetText("")
	xpFrame:SetFontSize(configuration.fontSizeProcent or 24)
	xpFrame.currText = ""

	local txtDetail = UI.CreateFrame("Text", WT.UniqueName("wtXP"), wrapper)
	txtDetail:SetText("")
	txtDetail:SetFontSize(configuration.fontSize or 10)
	xpFrame.detail = txtDetail

	xpHeading:SetPoint("TOPCENTER", wrapper, "TOPCENTER", 0, 5)
	xpFrame:SetPoint("TOPCENTER", xpHeading, "BOTTOMCENTER", 0, -5)
	txtDetail:SetPoint("TOPCENTER", xpFrame, "BOTTOMCENTER", 0, -6)

	if configuration.font == nil or configuration.font == "#Default" then
		xpHeading:SetFont("Rift", "$Flareserif_medium")
		xpFrame:SetFont("Rift", "$Flareserif_medium")
		txtDetail:SetFont("Rift", "$Flareserif_medium")
	else
		Library.Media.SetFont(xpHeading, configuration.font)
		Library.Media.SetFont(xpFrame, configuration.font)
		Library.Media.SetFont(txtDetail, configuration.font)
	end

	if configuration.outlineTextLight == true then
		xpHeading:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
		xpFrame:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
		txtDetail:SetEffectGlow({ colorR = 0.48, colorG = 0.34, colorB = 0.17, strength = 3, })
	else 
		xpHeading:SetEffectGlow({ strength = 1 })
		xpFrame:SetEffectGlow({ strength = 1 })
		txtDetail:SetEffectGlow({ strength = 1 })
	end	
	
	table.insert(xpGadgets, xpFrame)

	OnExperience(0,Inspect.TEMPORARY.Experience())	

	return wrapper, { resizable={150, 64, 150, 70} }
	
end


local dialog = false

local function ConfigDialog(container)	

	local lfont = Library.Media.GetFontIds("font")
	local listfont = {}
	for v, k in pairs(lfont) do
		table.insert(listfont, { value=k })
	end
	
	dialog = WT.Dialog(container)
		:Label("The XP Percent gadget has no additional configuration options")	
		:Checkbox("showBackground", "Show Background", true)
		:Checkbox("showTextEXPERIENCE", "Show text 'EXPERIENCE'", true)
		:Checkbox("outlineTextLight", "Show outline(light) text", false)
		:Select("font", "Font", "#Default", lfont, true)
		:Slider("fontSize", "Font Size", 10, true)	
		:Slider("fontSizeProcent", "Font Size %", 24, true)	
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

WT.Gadget.RegisterFactory("XPPercent",
	{
		name="XP Percent",
		description="XP Percentage Display",
		author="Wildtide",
		version="1.0.0",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})

local function OnPlayerAvailable()
	OnExperience(0, Inspect.TEMPORARY.Experience())
end

Command.Event.Attach(Event.TEMPORARY.Experience, OnExperience, "OnExperience")
Command.Event.Attach(WT.Event.PlayerAvailable, OnPlayerAvailable, "XPPercentGadget_OnPlayerAvailable")	
