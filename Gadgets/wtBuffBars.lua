--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.1.3
      Project Date (UTC)  : 2012-08-07T01:23:40Z
      File Modified (UTC) : 2012-08-07T01:23:40Z (Wildtide)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

local initDone = false
local dialog = false

-- Initialiser waits until a Gadget is created before registering event handlers
-- This should be done in all gadgets to save on overhead when no gadget instances exist 
local function Init()
	table.insert(WT.Event.PlayerAvailable, {OnPlayerAvailable, AddonId, "BuffBars_OnPlayerAvailable"})	
	initDone = true
end

local filterPanel = nil

local selUnitToTrack = nil
local labMaxBarCount = nil
local sldMaxBarCount = nil
local radGrowUp = nil
local radGrowDown = nil
local radGroupGrow = nil
local radSortUp = nil
local radSortDown = nil
local radGroupSort = nil
local txtHeading = nil
local chkTooltips = nil
local chkOutline = nil
local chkBorder = nil
local chkCancel = nil
local colorBuffColour = nil
local colorDebuffColour = nil
local colorBuffBackground = nil
local colorDebuffBackground = nil
local colorBuffText = nil
local colorDebuffText = nil
local labBarSpacing = nil
local sldBarSpacing = nil
local chkUsePriority = nil
local sldMyBuffPriority = nil
local sldUnitBuffPriority = nil
local sldOtherBuffPriority = nil
local sldMyDebuffPriority = nil
local sldUnitDebuffPriority = nil
local sldOtherDebuffPriority = nil
local labMyBuffPriority = nil
local labUnitBuffPriority = nil
local labOtherBuffPriority = nil
local labMyDebuffPriority = nil
local labUnitDebuffPriority = nil
local labOtherDebuffPriority = nil

local function ConfigDialog(container)

	local tabs = UI.CreateFrame("SimpleLifeTabView", "rfTabs", container)
	tabs:SetPoint("TOPLEFT", container, "TOPLEFT")
	tabs:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, -32)
	
	local frmConfig = UI.CreateFrame("Frame", "rfConfig", tabs.tabContent)
	local frmConfigInner = UI.CreateFrame("Frame", "bbConfigInner", frmConfig)
	frmConfigInner:SetPoint("TOPLEFT", frmConfig, "TOPLEFT", 12, 12)
	frmConfigInner:SetPoint("BOTTOMRIGHT", frmConfig, "BOTTOMRIGHT", -12, -12)
	
	local frmAppearance = UI.CreateFrame("Frame", "rfMacros", tabs.tabContent)
	local frmAppearanceInner = UI.CreateFrame("Frame", "bbFiltersInner", frmAppearance)
	frmAppearanceInner:SetPoint("TOPLEFT", frmAppearance, "TOPLEFT", 4, 4)
	frmAppearanceInner:SetPoint("BOTTOMRIGHT", frmAppearance, "BOTTOMRIGHT", -4, -4)
	
	local frmPriority = UI.CreateFrame("Frame", "rfPriority", tabs.tabContent)
	local frmPriorityInner = UI.CreateFrame("Frame", "bbPriorityInner", frmPriority)
	frmPriorityInner:SetPoint("TOPLEFT", frmPriority, "TOPLEFT", 12, 12)
	frmPriorityInner:SetPoint("BOTTOMRIGHT", frmPriority, "BOTTOMRIGHT", -12, -12)

	tabs:SetTabPosition("top")
	tabs:AddTab("Configuration", frmConfig)
	tabs:AddTab("Appearance", frmAppearance)
	tabs:AddTab("Priority", frmPriority)

	selUnitToTrack = WT.Control.Select.Create(frmConfigInner, "Unit to Track:", "player", 
	{ 
		{text = "Player", value = "player"}, 
		{text = "Target", value = "player.target"}, 
		{text = "Target's Target", value = "player.target.target"}, 
		{text = "Focus", value = "focus"}, 
		{text = "Focus's Target", value = "focus.target"}, 
		{text = "Pet", value = "player.pet"}, 
		{text = "Pet's Target", value = "player.pet.target"}, 
	})
		
	labMaxBarCount = UI.CreateFrame("Text", "labMaxBarCount", frmConfigInner)
	sldMaxBarCount = UI.CreateFrame("SimpleLifeSlider", "sldMaxBarCount", frmConfigInner)
	radGrowUp = UI.CreateFrame("SimpleLifeRadioButton", "radGrowUp", frmConfigInner)
	radGrowDown = UI.CreateFrame("SimpleLifeRadioButton", "radGrowDown", frmConfigInner)
	radSortUp = UI.CreateFrame("SimpleLifeRadioButton", "radSortUp", frmConfigInner)
	radSortDown = UI.CreateFrame("SimpleLifeRadioButton", "radSortDown", frmConfigInner)
	txtHeading = UI.CreateFrame("RiftTextfield", "txtHeading", frmConfigInner)
	local labHeading = UI.CreateFrame("Text", "labHeading", frmConfigInner)
	chkTooltips = UI.CreateFrame("SimpleLifeCheckbox", "chkTooltips", frmConfig)
	chkOutline = UI.CreateFrame("SimpleLifeCheckbox", "chkOutline", frmConfig)
	chkBorder = UI.CreateFrame("SimpleLifeCheckbox", "chkBorder", frmConfig)
	chkCancel = UI.CreateFrame("SimpleLifeCheckbox", "chkCancel", frmConfig)
	labBarSpacing = UI.CreateFrame("Text", "labBarSpacing", frmAppearanceInner)
	sldBarSpacing = UI.CreateFrame("SimpleLifeSlider", "sldBarSpacing", frmAppearanceInner)
	
	chkUsePriority = UI.CreateFrame("SimpleLifeCheckbox", "chkUsePriority", frmPriority)
	sldMyBuffPriority = UI.CreateFrame("SimpleLifeSlider", "sldMyBuffPriority", frmPriority)
	sldUnitBuffPriority = UI.CreateFrame("SimpleLifeSlider", "sldUnitBuffPriority", frmPriority)
	sldOtherBuffPriority = UI.CreateFrame("SimpleLifeSlider", "sldOtherBuffPriority", frmPriority)
	sldMyDebuffPriority = UI.CreateFrame("SimpleLifeSlider", "sldMyDebuffPriority", frmPriority)
	sldUnitDebuffPriority = UI.CreateFrame("SimpleLifeSlider", "sldUnitDebuffPriority", frmPriority)
	sldOtherDebuffPriority = UI.CreateFrame("SimpleLifeSlider", "sldOtherDebuffPriority", frmPriority)
	labMyBuffPriority = UI.CreateFrame("Text", "labMyBuffPriority", frmPriority)
	labUnitBuffPriority = UI.CreateFrame("Text", "labUnitBuffPriority", frmPriority)
	labOtherBuffPriority = UI.CreateFrame("Text", "labOtherBuffPriority", frmPriority)
	labMyDebuffPriority = UI.CreateFrame("Text", "labMyDebuffPriority", frmPriority)
	labUnitDebuffPriority = UI.CreateFrame("Text", "labUnitDebuffPriority", frmPriority)
	labOtherDebuffPriority = UI.CreateFrame("Text", "labOtherDebuffPriority", frmPriority)
	
	labMaxBarCount:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	labMaxBarCount:SetFontColor(1,0.97,0.84,1)
	labMaxBarCount:SetFontSize(14)
	--labMaxBarCount:SetFont(AddonId, "blank-Bold")
	
	labHeading:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	labHeading:SetFontColor(1,0.97,0.84,1)
	labHeading:SetFontSize(14)
	--labHeading:SetFont(AddonId, "blank-Bold")
	
	labBarSpacing:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	labBarSpacing:SetFontColor(1,0.97,0.84,1)
	labBarSpacing:SetFontSize(14)
	--labBarSpacing:SetFont(AddonId, "blank-Bold")
	
	labMyBuffPriority:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	labMyBuffPriority:SetFontColor(1,0.97,0.84,1)
	labMyBuffPriority:SetFontSize(14)
	--labMyBuffPriority:SetFont(AddonId, "blank-Bold")
	
	labUnitBuffPriority:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	labUnitBuffPriority:SetFontColor(1,0.97,0.84,1)
	labUnitBuffPriority:SetFontSize(14)
	--labUnitBuffPriority:SetFont(AddonId, "blank-Bold")	
	
	labOtherBuffPriority:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	labOtherBuffPriority:SetFontColor(1,0.97,0.84,1)
	labOtherBuffPriority:SetFontSize(14)
	--labOtherBuffPriority:SetFont(AddonId, "blank-Bold")
	
	labMyDebuffPriority:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	labMyDebuffPriority:SetFontColor(1,0.97,0.84,1)
	labMyDebuffPriority:SetFontSize(14)
	--labMyDebuffPriority:SetFont(AddonId, "blank-Bold")
	
	labUnitDebuffPriority:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	labUnitDebuffPriority:SetFontColor(1,0.97,0.84,1)
	labUnitDebuffPriority:SetFontSize(14)
	--labUnitDebuffPriority:SetFont(AddonId, "blank-Bold")
	
	labOtherDebuffPriority:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	labOtherDebuffPriority:SetFontColor(1,0.97,0.84,1)
	labOtherDebuffPriority:SetFontSize(14)
	--labOtherDebuffPriority:SetFont(AddonId, "blank-Bold")
	
	radGroupGrow = Library.LibSimpleWidgetsLifeEdition.RadioButtonGroup("radGroupGrow")
	radGroupGrow:AddRadioButton(radGrowUp)
	radGroupGrow:AddRadioButton(radGrowDown)

	radGroupSort = Library.LibSimpleWidgetsLifeEdition.RadioButtonGroup("radGroupSort")
	radGroupSort:AddRadioButton(radSortUp)
	radGroupSort:AddRadioButton(radSortDown)

	labMaxBarCount:SetText("Maximum Number of Bars:")
	labMaxBarCount:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	radGrowUp:SetText("Grow Up")
	radGrowDown:SetText("Grow Down")
	radSortUp:SetText("Ascending")
	radSortDown:SetText("Descending")
	txtHeading:SetText("")
	labHeading:SetText("Heading:");
	chkTooltips:SetText("Show Tooltips");
	chkOutline:SetText("Show Outline");
	chkBorder:SetText("Show Border");
	chkCancel:SetText("Right Click to Cancel");
	labBarSpacing:SetText("Bar Spacing:")
	
	chkUsePriority:SetText("Prioritise buffs by source")
	labMyBuffPriority:SetText("Buffs Cast by Player:")
	labUnitBuffPriority:SetText("Buffs Cast by Unit:")
	labOtherBuffPriority:SetText("Buffs Cast by Anyone Else:")
	labMyDebuffPriority:SetText("Debuffs Cast by Player:")
	labUnitDebuffPriority:SetText("Debuffs Cast by Unit:")
	labOtherDebuffPriority:SetText("Debuffs Cast by Anyone Else:")
	
	chkTooltips:SetChecked(true)
	chkOutline:SetChecked(true)
	chkCancel:SetChecked(true)
	chkBorder:SetChecked(true)

	radGrowDown:SetSelected(true)
	radSortDown:SetSelected(true)

	sldMaxBarCount:SetRange(1, 50)
	sldMaxBarCount:SetPosition(10, true)

	sldBarSpacing:SetRange(0, 10)
	sldBarSpacing:SetPosition(3, true)
	
	chkUsePriority:SetChecked(false)
	sldMyBuffPriority:SetRange(1, 6)
	sldUnitBuffPriority:SetRange(1, 6)
	sldOtherBuffPriority:SetRange(1, 6)
	sldMyDebuffPriority:SetRange(1, 6)
	sldUnitDebuffPriority:SetRange(1, 6)
	sldOtherDebuffPriority:SetRange(1, 6)
	sldMyBuffPriority:SetPosition(1, true)
	sldUnitBuffPriority:SetPosition(2, true)
	sldOtherBuffPriority:SetPosition(3, true)
	sldMyDebuffPriority:SetPosition(1, true)
	sldUnitDebuffPriority:SetPosition(2, true)
	sldOtherDebuffPriority:SetPosition(3, true)
	sldMyBuffPriority:SetWidth(220)
	sldUnitBuffPriority:SetWidth(220)
	sldOtherBuffPriority:SetWidth(220)
	sldMyDebuffPriority:SetWidth(220)
	sldUnitDebuffPriority:SetWidth(220)
	sldOtherDebuffPriority:SetWidth(220)

	selUnitToTrack:SetPoint("TOPLEFT", frmConfigInner, "TOPLEFT", 0, 0)

	labMaxBarCount:SetPoint("TOP", chkTooltips, "BOTTOM", nil, 16) 
	labMaxBarCount:SetPoint("LEFT", frmConfigInner, "LEFT")
	sldMaxBarCount:SetPoint("TOPLEFT", labMaxBarCount, "BOTTOMLEFT", 0, 0) 
	sldMaxBarCount:SetWidth(220)

	radGrowUp:SetPoint("TOP", sldMaxBarCount, "TOP")
	radGrowUp:SetPoint("LEFT", frmConfigInner, "CENTERX")
	radGrowDown:SetPoint("TOPLEFT", radGrowUp, "TOPLEFT", 100, 0)

	radSortUp:SetPoint("TOPLEFT", radGrowUp, "BOTTOMLEFT", 0, 4)
	radSortDown:SetPoint("TOPLEFT", radGrowDown, "BOTTOMLEFT", 0, 4)

	labHeading:SetPoint("TOPLEFT", selUnitToTrack, "BOTTOMLEFT", 0, 4)
	
	txtHeading:SetPoint("TOP", labHeading, "TOP")
	txtHeading:SetPoint("LEFT", labHeading, "RIGHT")
	txtHeading:SetBackgroundColor(0.2, 0.2, 0.2, 1.0)

	chkTooltips:SetPoint("TOPLEFT", labHeading, "BOTTOMLEFT", 0, 4)
	chkCancel:SetPoint("TOPLEFT", chkTooltips, "TOPRIGHT", 8, 0)
	chkOutline:SetPoint("TOPLEFT", chkCancel, "TOPRIGHT", 8, 0)
	chkBorder:SetPoint("TOPLEFT", chkOutline, "TOPRIGHT", 8, 0)

	filterPanel = data.CreateBuffFilterPanel(frmConfigInner)
	filterPanel.frmConfigInner:SetPoint("TOPLEFT", sldMaxBarCount, "BOTTOMLEFT", 0, 28)
	filterPanel.frmConfigInner:SetPoint("BOTTOMRIGHT", frmConfigInner, "BOTTOMRIGHT")

	local lblBuffColour = UI.CreateFrame("Text", "lblBuffColour", frmAppearanceInner)
	lblBuffColour:SetText("Buff Color:")
	lblBuffColour:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 4, 10)
	lblBuffColour:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	lblBuffColour:SetFontColor(1,0.97,0.84,1)
	--lblBuffColour:SetFont(AddonId, "blank-Bold")
	lblBuffColour:SetFontSize(14)

	colorBuffColour = WT.CreateColourPicker(frmAppearanceInner, 0.2,0.2,0.6,1.0)
	colorBuffColour:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 100, 10)

	local lblDebuffColour = UI.CreateFrame("Text", "lblBuffColour", frmAppearanceInner)
	lblDebuffColour:SetText("Debuff Color:")
	lblDebuffColour:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 4, 36)
	lblDebuffColour:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	lblDebuffColour:SetFontColor(1,0.97,0.84,1)
	--lblDebuffColour:SetFont(AddonId, "blank-Bold")
	lblDebuffColour:SetFontSize(14)

	colorDebuffColour = WT.CreateColourPicker(frmAppearanceInner,0.6,0.1,0.1,1)
	colorDebuffColour:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 100, 36)

	local lblBuffBackground = UI.CreateFrame("Text", "lblBuffBackground", frmAppearanceInner)
	lblBuffBackground:SetText("Buff Background:")
	lblBuffBackground:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 160, 10)
	lblBuffBackground:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	lblBuffBackground:SetFontColor(1,0.97,0.84,1)
	--lblBuffBackground:SetFont(AddonId, "blank-Bold")
	lblBuffBackground:SetFontSize(14)

	colorBuffBackground = WT.CreateColourPicker(frmAppearanceInner, 0.2,0.2,0.6,0.3)
	colorBuffBackground:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 280, 10)

	local lblDebuffBackground = UI.CreateFrame("Text", "lblBuffBackground", frmAppearanceInner)
	lblDebuffBackground:SetText("Debuff Background:")
	lblDebuffBackground:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 160, 36)
	lblDebuffBackground:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	lblDebuffBackground:SetFontColor(1,0.97,0.84,1)
	--lblDebuffBackground:SetFont(AddonId, "blank-Bold")
	lblDebuffBackground:SetFontSize(14)

	colorDebuffBackground = WT.CreateColourPicker(frmAppearanceInner,0.6,0.1,0.1,0.3)
	colorDebuffBackground:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 280, 36)

	local lblBuffText = UI.CreateFrame("Text", "lblBuffText", frmAppearanceInner)
	lblBuffText:SetText("Buff Text:")
	lblBuffText:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 340, 10)
	lblBuffText:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	lblBuffText:SetFontColor(1,0.97,0.84,1)
	--lblBuffText:SetFont(AddonId, "blank-Bold")
	lblBuffText:SetFontSize(14)

	colorBuffText = WT.CreateColourPicker(frmAppearanceInner, 1,1,1,1)
	colorBuffText:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 420, 10)

	local lblDebuffText = UI.CreateFrame("Text", "lblBuffText", frmAppearanceInner)
	lblDebuffText:SetText("Debuff Text:")
	lblDebuffText:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 340, 36)
	lblDebuffText:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
	lblDebuffText:SetFontColor(1,0.97,0.84,1)
	--lblDebuffText:SetFont(AddonId, "blank-Bold")
	lblDebuffText:SetFontSize(14)

	colorDebuffText = WT.CreateColourPicker(frmAppearanceInner, 1,1,1,1)
	colorDebuffText:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 420, 36)

	labBarSpacing:SetPoint("TOPLEFT", lblDebuffColour, "BOTTOMLEFT", 0, 16) 
	sldBarSpacing:SetPoint("TOPLEFT", labBarSpacing, "BOTTOMLEFT", 0, 0) 
	sldBarSpacing:SetWidth(220)
	
	chkUsePriority:SetPoint("TOPLEFT", frmPriorityInner, "TOPLEFT", 0, 4)
	labMyBuffPriority:SetPoint("TOPLEFT", chkUsePriority, "BOTTOMLEFT", 0, 4)
	sldMyBuffPriority:SetPoint("TOPLEFT", labMyBuffPriority, "BOTTOMLEFT")
	labUnitBuffPriority:SetPoint("TOPLEFT", sldMyBuffPriority, "BOTTOMLEFT", 0, 4)
	sldUnitBuffPriority:SetPoint("TOPLEFT", labUnitBuffPriority, "BOTTOMLEFT")
	labOtherBuffPriority:SetPoint("TOPLEFT", sldUnitBuffPriority, "BOTTOMLEFT", 0, 4)
	sldOtherBuffPriority:SetPoint("TOPLEFT", labOtherBuffPriority, "BOTTOMLEFT")
	
	labMyDebuffPriority:SetPoint("TOP", labMyBuffPriority, "TOP")
	labMyDebuffPriority:SetPoint("LEFT", frmPriorityInner, "CENTERX")
	sldMyDebuffPriority:SetPoint("TOPLEFT", labMyDebuffPriority, "BOTTOMLEFT")
	labUnitDebuffPriority:SetPoint("TOPLEFT", sldMyDebuffPriority, "BOTTOMLEFT", 0, 4)
	sldUnitDebuffPriority:SetPoint("TOPLEFT", labUnitDebuffPriority, "BOTTOMLEFT")
	labOtherDebuffPriority:SetPoint("TOPLEFT", sldUnitDebuffPriority, "BOTTOMLEFT", 0, 4)
	sldOtherDebuffPriority:SetPoint("TOPLEFT", labOtherDebuffPriority, "BOTTOMLEFT")

end

local function GetConfiguration()

	local config = {}
	config.unitSpec = selUnitToTrack:GetText()

	filterPanel:WriteToConfiguration(config)

	config.maxBars = sldMaxBarCount:GetPosition()

	config.tooltips = chkTooltips:GetChecked()
	config.outline = chkOutline:GetChecked()
	config.border = chkBorder:GetChecked()
	config.cancel = chkCancel:GetChecked()
	config.sortDescending = radSortDown:GetSelected()

	config.barSpacing = sldBarSpacing:GetPosition()
	
	config.buffFontColour = { colorBuffText:GetColor() }
	config.buffColour = { colorBuffColour:GetColor() }
	config.buffBackground = { colorBuffBackground:GetColor() }
	
	config.debuffFontColour = { colorDebuffText:GetColor() }
	config.debuffColour = { colorDebuffColour:GetColor() }
	config.debuffBackground = { colorDebuffBackground:GetColor() }
	
	config.heading = txtHeading:GetText()
	config.headingFontColour = {1,1,1,1}
	
	if radGrowUp:GetSelected() then
		config.grow = "up"
	else
		config.grow = "down"
	end
	
	config.usePriority = chkUsePriority:GetChecked()
	config.myBuffPriority = sldMyBuffPriority:GetPosition()
	config.unitBuffPriority = sldUnitBuffPriority:GetPosition()
	config.otherBuffPriority = sldOtherBuffPriority:GetPosition()
	config.myDebuffPriority = sldMyDebuffPriority:GetPosition()
	config.unitDebuffPriority = sldUnitDebuffPriority:GetPosition()
	config.otherDebuffPriority = sldOtherDebuffPriority:GetPosition()
	
	return config 
end

local function SetConfiguration(config)

	selUnitToTrack:SetText(config.unitSpec)
	txtHeading:SetText(config.heading or "")

	chkTooltips:SetChecked(WT.Utility.ToBoolean(config.tooltips)) 
	chkOutline:SetChecked(WT.Utility.ToBoolean(config.outline)) 
	chkBorder:SetChecked(WT.Utility.ToBoolean(config.border)) 
	chkCancel:SetChecked(WT.Utility.ToBoolean(config.cancel))
	 
	if config.sortDescending then
		radSortDown:SetSelected(true)
	else
		radSortUp:SetSelected(true)
	end

	colorBuffColour:SetColor(unpack(config.buffColour))
	colorBuffBackground:SetColor(unpack(config.buffBackground))
	colorBuffText:SetColor(unpack(config.buffFontColour))

	colorDebuffColour:SetColor(unpack(config.debuffColour))
	colorDebuffBackground:SetColor(unpack(config.debuffBackground))
	colorDebuffText:SetColor(unpack(config.debuffFontColour))

	filterPanel:ReadFromConfiguration(config)

	sldMaxBarCount:SetPosition(config.maxBars or 10) 
	sldBarSpacing:SetPosition(config.barSpacing) 

	if config.grow == "up" then
		radGrowUp:SetSelected(true)
	else
		radGrowDown:SetSelected(true)
	end
	
	chkUsePriority:SetChecked(WT.Utility.ToBoolean(config.usePriority) or false)
	sldMyBuffPriority:SetPosition(config.myBuffPriority or 1)
	sldUnitBuffPriority:SetPosition(config.unitBuffPriority or 2)
	sldOtherBuffPriority:SetPosition(config.otherBuffPriority or 3)
	sldMyDebuffPriority:SetPosition(config.myDebuffPriority or 1)
	sldUnitDebuffPriority:SetPosition(config.unitDebuffPriority or 2)
	sldOtherDebuffPriority:SetPosition(config.otherDebuffPriority or 3)
end

local function OnPlayerAvailable()
	print("BuffBars player available triggered")
end

	WT.Gadget.RegisterFactory("BuffBars",
	{
		name="Buff Bars",
		description="Buff Bars Gadget",
		author="Wildtide",
		version="1.0.0",
		iconTexAddon = AddonId,
		iconTexFile = "img/wtBuffBars.png",
		["Create"] = WT.Gadget.ConfigureBuffBars,
		["Reconfigure"] = WT.Gadget.ConfigureBuffBars,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})

