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
	table.insert(WT.Event.PlayerAvailable, {OnPlayerAvailable, AddonId, "BuffIcons_OnPlayerAvailable"})	
	initDone = true
end

local filterPanel = nil

local selUnitToTrack = nil
local chkTooltips = nil
local chkCancel = nil
local radGroupSort = nil
local radSortUp = nil
local radSortDown = nil

local colorBuffBorder = nil
local colorDebuffBorder = nil

local colorBuffBackground = nil
local colorDebuffBackground = nil

local colorBuffText = nil
local colorDebuffText = nil

local sldIconSize = nil
local sldMarginHorizontal = nil
local sldMarginVertical = nil
local sldPaddingTop = nil
local sldPaddingBottom = nil
local sldPaddingLeft = nil
local sldPaddingRight = nil
local sldTimerSize = nil
local sldStackSize = nil
local sldBorderWidth = nil
local sldTimerX = nil
local sldTimerY = nil
local sldStackX = nil
local sldStackY = nil
local sldRows = nil
local sldCols = nil

local chkShowTimer = nil
local chkShowStack = nil

local chkEnableFlashing = nil
local chkSplitDebuffs = nil
local chkTextOutline = nil
local chkSortByTime = nil

local radFillFromTopLeft = nil
local radFillFromTopRight = nil
local radFillFromBottomLeft = nil
local radFillFromBottomRight = nil
local radGroupFillFrom = nil

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

local preview = nil

local testBuff01 = 
{
	id = "example01",
	icon = "Data/\\UI\\ability_icons\\discombobulate2a.dds",
	stack = 2,
	timerText = "15s",
	debuff = false
}

local testBuff02 = 
{
	id = "example02",
	icon = "Data/\\UI\\ability_icons\\plant1.dds",
	stack = 5,
	timerText = "5m",
	debuff = true
}

local testBuff03 = 
{
	id = "example03",
	icon = "Data/\\UI\\ability_icons\\arcaneshield4.dds",
	stack = nil,
	timerText = "49m",
	debuff = false
}

local testBuff04 = 
{
	id = "example04",
	icon = "Data/\\UI\\ability_icons\\planarite_gem_a.dds",
	stack = nil,
	timerText = "",
	debuff = true
}


local function UpdatePreview()

	local configuration = data.BuffIcons_GetConfiguration()
	preview.config = configuration
	configuration.rows = 2
	configuration.cols = 2

	local slotHeight = configuration.iconSize + (configuration.borderWidth * 2) + configuration.paddingTop + configuration.paddingBottom 
	local slotWidth = configuration.iconSize + (configuration.borderWidth * 2) + configuration.paddingLeft + configuration.paddingRight
	local totalSlotHeight = configuration.rows * slotHeight
	local totalSlotWidth = configuration.cols * slotWidth
	local totalMarginHeight = (configuration.rows - 1) * configuration.marginVertical
	local totalMarginWidth = (configuration.cols - 1) * configuration.marginHorizontal

	data.LayoutIcon(preview.icon01, configuration)
	data.LayoutIcon(preview.icon02, configuration)
	data.LayoutIcon(preview.icon03, configuration)
	data.LayoutIcon(preview.icon04, configuration)	
	
	data.UpdateIcon(preview, preview.icon01, testBuff01)
	data.UpdateIcon(preview, preview.icon02, testBuff02)
	data.UpdateIcon(preview, preview.icon03, testBuff03)
	data.UpdateIcon(preview, preview.icon04, testBuff04)

	local col, row = 0, 0
	preview.icon01:SetPoint("TOPLEFT", preview, "TOPLEFT", 8 + (col * (slotWidth + configuration.marginHorizontal)), 8 + (row * (slotHeight + configuration.marginVertical)))
	col,row = 1,0
	preview.icon02:SetPoint("TOPLEFT", preview, "TOPLEFT", 8 + (col * (slotWidth + configuration.marginHorizontal)), 8 + (row * (slotHeight + configuration.marginVertical)))
	col,row = 0,1
	preview.icon03:SetPoint("TOPLEFT", preview, "TOPLEFT", 8 + (col * (slotWidth + configuration.marginHorizontal)), 8 + (row * (slotHeight + configuration.marginVertical)))
	col,row = 1,1
	preview.icon04:SetPoint("TOPLEFT", preview, "TOPLEFT", 8 + (col * (slotWidth + configuration.marginHorizontal)), 8 + (row * (slotHeight + configuration.marginVertical)))

	preview:SetWidth(16 + totalSlotWidth + totalMarginWidth)
	preview:SetHeight(16 + totalSlotHeight + totalMarginHeight)

end



local function GetConfiguration()

	local config = {}
	config.unitSpec = selUnitToTrack:GetText()

	filterPanel:WriteToConfiguration(config)

	config.tooltips = chkTooltips:GetChecked()
	config.cancel = chkCancel:GetChecked()
	config.sortDescending = radSortDown:GetSelected()	
	
	config.buffFontColour = { colorBuffText:GetColor() }
	config.buffBorderColour = { colorBuffBorder:GetColor() }
	config.buffBackground = { colorBuffBackground:GetColor() }
	
	config.debuffFontColour = { colorDebuffText:GetColor() }
	config.debuffBorderColour = { colorDebuffBorder:GetColor() }
	config.debuffBackground = { colorDebuffBackground:GetColor() }
	
	config.paddingTop = sldPaddingTop:GetPosition()
	config.paddingLeft = sldPaddingLeft:GetPosition()
	config.paddingBottom = sldPaddingBottom:GetPosition()
	config.paddingRight = sldPaddingRight:GetPosition()
	config.marginHorizontal = sldMarginHorizontal:GetPosition()
	config.marginVertical = sldMarginVertical:GetPosition()
	config.borderWidth = sldBorderWidth:GetPosition()
	config.timerFontSize = sldTimerSize:GetPosition() 
	config.stackFontSize = sldStackSize:GetPosition()
	config.timerX = sldTimerX:GetPosition()
	config.timerY = sldTimerY:GetPosition()
	config.stackX = sldStackX:GetPosition()
	config.stackY = sldStackY:GetPosition()
	
	config.rows = sldRows:GetPosition()
	config.cols = sldCols:GetPosition()
	
	config.timerAnchor = "TOPCENTER"
	config.stackAnchor = "TOPCENTER"

	config.showTimer = chkShowTimer:GetChecked()
	config.showStack = chkShowStack:GetChecked()
	
	config.enableFlashing = chkEnableFlashing:GetChecked()
	config.splitDebuffs = chkSplitDebuffs:GetChecked()
	config.textOutline = chkTextOutline:GetChecked()
	config.sortByTime = chkSortByTime:GetChecked()
	
	config.iconSize = sldIconSize:GetPosition()
	
	config.fillFrom = "TOPLEFT"
	if radFillFromTopRight:GetSelected() then config.fillFrom = "TOPRIGHT" end
	if radFillFromBottomLeft:GetSelected() then config.fillFrom = "BOTTOMLEFT" end
	if radFillFromBottomRight:GetSelected() then config.fillFrom = "BOTTOMRIGHT" end

	if chkUsePriority then
		config.usePriority = chkUsePriority:GetChecked()
		config.myBuffPriority = sldMyBuffPriority:GetPosition()
		config.unitBuffPriority = sldUnitBuffPriority:GetPosition()
		config.otherBuffPriority = sldOtherBuffPriority:GetPosition()
		config.myDebuffPriority = sldMyDebuffPriority:GetPosition()
		config.unitDebuffPriority = sldUnitDebuffPriority:GetPosition()
		config.otherDebuffPriority = sldOtherDebuffPriority:GetPosition()
	else
		config.usePriority = false
		config.myBuffPriority = 1
		config.unitBuffPriority = 2
		config.otherBuffPriority = 3
		config.myDebuffPriority = 1
		config.unitDebuffPriority = 2
		config.otherDebuffPriority = 3
	end
	
	return config 
end
data.BuffIcons_GetConfiguration = GetConfiguration

local function SetConfiguration(config)

	selUnitToTrack:SetText(config.unitSpec)

	chkTooltips:SetChecked(WT.Utility.ToBoolean(config.tooltips)) 
	chkCancel:SetChecked(WT.Utility.ToBoolean(config.cancel))
	
	if config.sortDescending then
		radSortDown:SetSelected(true)
	else
		radSortUp:SetSelected(true)
	end
	 
	colorBuffBorder:SetColor(unpack(config.buffBorderColour))
	colorBuffBackground:SetColor(unpack(config.buffBackground))
	colorBuffText:SetColor(unpack(config.buffFontColour))

	colorDebuffBorder:SetColor(unpack(config.debuffBorderColour))
	colorDebuffBackground:SetColor(unpack(config.debuffBackground))
	colorDebuffText:SetColor(unpack(config.debuffFontColour))

	sldIconSize:SetPosition(config.iconSize) 
	sldPaddingTop:SetPosition(config.paddingTop)
	sldPaddingLeft:SetPosition(config.paddingLeft)
	sldPaddingBottom:SetPosition(config.paddingBottom) 
	sldPaddingRight:SetPosition(config.paddingRight)
	sldMarginHorizontal:SetPosition(config.marginHorizontal) 
	sldMarginVertical:SetPosition(config.marginVertical) 
	sldBorderWidth:SetPosition(config.borderWidth) 
	sldTimerSize:SetPosition(config.timerFontSize or 10)  
	sldStackSize:SetPosition(config.stackFontSize or 10) 
	sldTimerX:SetPosition(config.timerX or 0) 
	sldTimerY:SetPosition(config.timerY or 0) 
	sldStackX:SetPosition(config.stackX or 0) 
	sldStackY:SetPosition(config.stackY or 0) 

	chkShowTimer:SetChecked(WT.Utility.ToBoolean(config.showTimer))
	chkShowStack:SetChecked(WT.Utility.ToBoolean(config.showStack))
	chkTextOutline:SetChecked(WT.Utility.ToBoolean(config.textOutline))
	chkEnableFlashing:SetChecked(WT.Utility.ToBoolean(config.enableFlashing))
	chkSplitDebuffs:SetChecked(WT.Utility.ToBoolean(config.splitDebuffs))
	chkSortByTime:SetChecked(WT.Utility.ToBoolean(config.sortByTime))

	sldRows:SetPosition(config.rows or 4) 
	sldCols:SetPosition(config.cols or 4)
	
	chkUsePriority:SetChecked(WT.Utility.ToBoolean(config.usePriority) or false)
	sldMyBuffPriority:SetPosition(config.myBuffPriority or 1)
	sldUnitBuffPriority:SetPosition(config.unitBuffPriority or 2)
	sldOtherBuffPriority:SetPosition(config.otherBuffPriority or 3)
	sldMyDebuffPriority:SetPosition(config.myDebuffPriority or 1)
	sldUnitDebuffPriority:SetPosition(config.unitDebuffPriority or 2)
	sldOtherDebuffPriority:SetPosition(config.otherDebuffPriority or 3)

	if config.fillFrom == "TOPRIGHT" then
		radFillFromTopRight:SetSelected(true)
	elseif config.fillFrom == "BOTTOMLEFT" then
		radFillFromBottomLeft:SetSelected(true)
	elseif config.fillFrom == "BOTTOMRIGHT" then
		radFillFromBottomRight:SetSelected(true)
	else
		radFillFromTopLeft:SetSelected(true)
	end

	filterPanel:ReadFromConfiguration(config)
	
	UpdatePreview()

end


local function CreateSlider(parent, placeUnder, text, minRange, maxRange, default)
	
	local label = UI.CreateFrame("Text", "txtSlider", parent)
	label:SetText(text)
	label:SetPoint("TOPLEFT", placeUnder, "BOTTOMLEFT", 0, 4)
	
	local slider = UI.CreateFrame("SimpleSlider", "sldSlider", parent)
	slider:SetRange(minRange, maxRange)
	slider:SetPosition(default)
	slider:SetPoint("TOPLEFT", label, "TOPLEFT", 96, 0)
	slider.Event.SliderChange = UpdatePreview
	slider:SetWidth(150)
	
	slider.Label = label
	
	return slider
	
end


local function ConfigDialog(container)

	local tabs = UI.CreateFrame("SimpleTabView", "rfTabs", container)
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

	local frmLayout = UI.CreateFrame("Frame", "rfMacros", tabs.tabContent)
	local frmLayoutInner = UI.CreateFrame("Frame", "bbFiltersInner", frmLayout)
	frmLayoutInner:SetPoint("TOPLEFT", frmLayout, "TOPLEFT", 4, 4)
	frmLayoutInner:SetPoint("BOTTOMRIGHT", frmLayout, "BOTTOMRIGHT", -4, -4)

	local frmPriority = UI.CreateFrame("Frame", "rfPriority", tabs.tabContent)
	local frmPriorityInner = UI.CreateFrame("Frame", "bbPriorityInner", frmPriority)
	frmPriorityInner:SetPoint("TOPLEFT", frmPriority, "TOPLEFT", 12, 12)
	frmPriorityInner:SetPoint("BOTTOMRIGHT", frmPriority, "BOTTOMRIGHT", -12, -12)
	
	tabs:SetTabPosition("top")
	tabs:AddTab("Configuration", frmConfig)
	tabs:AddTab("Icon Style", frmAppearance)	
	tabs:AddTab("Grid Layout", frmLayout)	
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
		
	chkTooltips = UI.CreateFrame("SimpleCheckbox", "chkTooltips", frmConfig)
	chkCancel = UI.CreateFrame("SimpleCheckbox", "chkCancel", frmConfig)
	chkTooltips:SetText("Show Tooltips");
	chkCancel:SetText("Right Click to Cancel");
	
	radSortUp = UI.CreateFrame("SimpleRadioButton", "radSortUp", frmConfigInner)
	radSortDown = UI.CreateFrame("SimpleRadioButton", "radSortDown", frmConfigInner)
	radGroupSort = Library.LibSimpleWidgets.RadioButtonGroup("radGroupSort")
	radGroupSort:AddRadioButton(radSortUp)
	radGroupSort:AddRadioButton(radSortDown)
	radSortUp:SetText("Ascending")
	radSortDown:SetText("Descending")
	
	chkTooltips:SetChecked(true)
	chkCancel:SetChecked(true)

	selUnitToTrack:SetPoint("TOPLEFT", frmConfigInner, "TOPLEFT", 0, 0)

	chkTooltips:SetPoint("TOPLEFT", selUnitToTrack, "BOTTOMLEFT", 0, 4)
	chkCancel:SetPoint("TOPLEFT", chkTooltips, "TOPRIGHT", 8, 0)
	radSortUp:SetPoint("TOPLEFT", chkTooltips, "BOTTOMLEFT", 0, 4)
	radSortDown:SetPoint("TOPLEFT", chkCancel, "BOTTOMLEFT", 0, 4)
	radSortDown:SetSelected(true)

	filterPanel = data.CreateBuffFilterPanel(frmConfigInner)
	filterPanel.frmConfigInner:SetPoint("TOPLEFT", chkTooltips, "BOTTOMLEFT", 0, 28)
	filterPanel.frmConfigInner:SetPoint("BOTTOMRIGHT", frmConfigInner, "BOTTOMRIGHT")

	local lblBuffColour = UI.CreateFrame("Text", "lblBuffColour", frmAppearanceInner)
	lblBuffColour:SetText("Buff Border:")
	lblBuffColour:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 4, 10)

	colorBuffBorder = WT.CreateColourPicker(frmAppearanceInner, 0.2,0.6,0.2,1.0)
	colorBuffBorder:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 100, 10)

	local lblDebuffColour = UI.CreateFrame("Text", "lblBuffColour", frmAppearanceInner)
	lblDebuffColour:SetText("Debuff Border:")
	lblDebuffColour:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 4, 36)

	colorDebuffBorder = WT.CreateColourPicker(frmAppearanceInner,0.6,0.1,0.1,1)
	colorDebuffBorder:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 100, 36)

	local lblBuffBackground = UI.CreateFrame("Text", "lblBuffBackground", frmAppearanceInner)
	lblBuffBackground:SetText("Buff Background:")
	lblBuffBackground:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 160, 10)

	colorBuffBackground = WT.CreateColourPicker(frmAppearanceInner, 0.2,0.6,0.2,0.3)
	colorBuffBackground:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 280, 10)

	local lblDebuffBackground = UI.CreateFrame("Text", "lblBuffBackground", frmAppearanceInner)
	lblDebuffBackground:SetText("Debuff Background:")
	lblDebuffBackground:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 160, 36)

	colorDebuffBackground = WT.CreateColourPicker(frmAppearanceInner,0.6,0.1,0.1,0.3)
	colorDebuffBackground:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 280, 36)

	local lblBuffText = UI.CreateFrame("Text", "lblBuffText", frmAppearanceInner)
	lblBuffText:SetText("Buff Text:")
	lblBuffText:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 340, 10)

	colorBuffText = WT.CreateColourPicker(frmAppearanceInner, 1,1,1,1)
	colorBuffText:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 420, 10)

	local lblDebuffText = UI.CreateFrame("Text", "lblBuffText", frmAppearanceInner)
	lblDebuffText:SetText("Debuff Text:")
	lblDebuffText:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 340, 36)

	colorDebuffText = WT.CreateColourPicker(frmAppearanceInner, 1,1,1,1)
	colorDebuffText:SetPoint("TOPLEFT", frmAppearanceInner, "TOPLEFT", 420, 36)

	sldIconSize = CreateSlider(frmAppearanceInner, lblDebuffColour, "Icon Size:", 8, 64, 24)
	sldIconSize.Label:SetPoint("TOPLEFT", lblDebuffColour, "BOTTOMLEFT", 0, 12)
	sldPaddingTop = CreateSlider(frmAppearanceInner, sldIconSize.Label, "Padding Top:", 0, 32, 2)
	sldPaddingBottom = CreateSlider(frmAppearanceInner, sldPaddingTop.Label, "Padding Bottom:", 0, 32, 17)
	sldPaddingLeft = CreateSlider(frmAppearanceInner, sldPaddingBottom.Label, "Padding Left:", 0, 32, 2)
	sldPaddingRight = CreateSlider(frmAppearanceInner, sldPaddingLeft.Label, "Padding Right:", 0, 32, 2)
	sldBorderWidth = CreateSlider(frmAppearanceInner, sldPaddingRight.Label, "Border Width:", 0, 8, 1)
	sldTimerSize = CreateSlider(frmAppearanceInner, sldBorderWidth.Label, "Timer Size:", 6, 48, 10)
	sldStackSize = CreateSlider(frmAppearanceInner, sldTimerSize.Label, "Stack Size:", 6, 48, 16)
	sldTimerX = CreateSlider(frmAppearanceInner, sldStackSize.Label, "Timer X:", -128, 128, 0)
	sldTimerY = CreateSlider(frmAppearanceInner, sldTimerX.Label, "Timer Y:", -128, 128, 28)
	sldStackX = CreateSlider(frmAppearanceInner, sldTimerY.Label, "Stack X:", -128, 128, 0)
	sldStackY = CreateSlider(frmAppearanceInner, sldStackX.Label, "Stack Y:", -128, 128, 3)

	chkShowTimer = UI.CreateFrame("SimpleCheckbox", "chkShowTimer", frmAppearanceInner)
	chkShowTimer:SetText("Show Timer")
	chkShowTimer:SetChecked(true)
	chkShowTimer:SetPoint("CENTERLEFT", sldTimerSize, "CENTERRIGHT", 20, 0)
	chkShowTimer.Event.CheckboxChange = UpdatePreview

	chkShowStack = UI.CreateFrame("SimpleCheckbox", "chkShowStack", frmAppearanceInner)
	chkShowStack:SetText("Show Stacks")
	chkShowStack:SetChecked(true)
	chkShowStack:SetPoint("CENTERLEFT", sldStackSize, "CENTERRIGHT", 20, 0)
	chkShowStack.Event.CheckboxChange = UpdatePreview

	chkTextOutline = UI.CreateFrame("SimpleCheckbox", "chkShowTimer", frmAppearanceInner)
	chkTextOutline:SetText("Outline Text")
	chkTextOutline:SetChecked(true)
	chkTextOutline:SetPoint("CENTERLEFT", sldBorderWidth, "CENTERRIGHT", 20, 0)
	chkTextOutline.Event.CheckboxChange = UpdatePreview
	
	chkEnableFlashing = UI.CreateFrame("SimpleCheckbox", "chkEnableFlashing", frmAppearanceInner)
	chkEnableFlashing:SetText("Flash when close to expiry")
	chkEnableFlashing:SetChecked(false)
	chkEnableFlashing:SetPoint("CENTERLEFT", sldIconSize, "CENTERRIGHT", 20, 0)
	chkEnableFlashing.Event.CheckboxChange = UpdatePreview

	sldMarginHorizontal = CreateSlider(frmLayoutInner, frmLayoutInner, "Horiz Spacing:", 0, 32, 1)
	sldMarginHorizontal.Label:SetPoint("TOPLEFT", frmLayoutInner, "TOPLEFT", 4, 4)
	sldMarginVertical = CreateSlider(frmLayoutInner, sldMarginHorizontal.Label, "Vert Spacing:", 0, 32, 1)
	sldRows = CreateSlider(frmLayoutInner, sldMarginVertical.Label, "Grid Rows:", 1, 32, 4)
	sldCols = CreateSlider(frmLayoutInner, sldRows.Label, "Grid Columns:", 1, 32, 4)
	
	sldTimerX:SetWidth(350)
	sldTimerY:SetWidth(350)
	sldStackX:SetWidth(350)
	sldStackY:SetWidth(350)
	
	local labFillFrom = UI.CreateFrame("Text", "labFillFrom", frmLayoutInner)
	labFillFrom:SetText("Fill From:")
	labFillFrom:SetPoint("TOPLEFT", sldCols.Label, "BOTTOMLEFT", 0, 12)

	radFillFromTopLeft = UI.CreateFrame("SimpleRadioButton", "radFillFrom", frmLayoutInner)
	radFillFromTopRight = UI.CreateFrame("SimpleRadioButton", "radFillFrom", frmLayoutInner)
	radFillFromBottomLeft = UI.CreateFrame("SimpleRadioButton", "radFillFrom", frmLayoutInner)
	radFillFromBottomRight = UI.CreateFrame("SimpleRadioButton", "radFillFrom", frmLayoutInner)

	radFillFromTopLeft:SetText("Top Left")
	radFillFromTopRight:SetText("Top Right")
	radFillFromBottomLeft:SetText("Bottom Left")
	radFillFromBottomRight:SetText("Bottom Right")

	radGroupFillFrom = Library.LibSimpleWidgets.RadioButtonGroup("radGroupFillFrom")
	radGroupFillFrom:AddRadioButton(radFillFromTopLeft)
	radGroupFillFrom:AddRadioButton(radFillFromTopRight)
	radGroupFillFrom:AddRadioButton(radFillFromBottomLeft)
	radGroupFillFrom:AddRadioButton(radFillFromBottomRight)
	
	radFillFromTopLeft:SetPoint("TOPLEFT", labFillFrom, "TOPLEFT", 96, 0)
	radFillFromTopRight:SetPoint("TOPLEFT", radFillFromTopLeft, "TOPLEFT", 100, 0)
	radFillFromBottomLeft:SetPoint("TOPLEFT", radFillFromTopLeft, "BOTTOMLEFT", 0, 8)
	radFillFromBottomRight:SetPoint("TOPLEFT", radFillFromBottomLeft, "TOPLEFT", 100, 0)
	
	radFillFromTopLeft:SetSelected(true)

	chkSplitDebuffs = UI.CreateFrame("SimpleCheckbox", "chkEnableFlashing", frmLayoutInner)
	chkSplitDebuffs:SetText("Separate Debuffs from Buffs")
	chkSplitDebuffs:SetChecked(true)
	chkSplitDebuffs:SetPoint("TOP", radFillFromBottomLeft, "BOTTOM", nil, 12)
	chkSplitDebuffs:SetPoint("LEFT", labFillFrom, "LEFT", 0, nil)
	chkSplitDebuffs.Event.CheckboxChange = UpdatePreview

	chkSortByTime = UI.CreateFrame("SimpleCheckbox", "chkEnableFlashing", frmLayoutInner)
	chkSortByTime:SetText("Sort by Time Remaining")
	chkSortByTime:SetChecked(false)
	chkSortByTime:SetPoint("TOPLEFT", chkSplitDebuffs, "BOTTOMLEFT", 0, 8)
	
	preview = UI.CreateFrame("Frame", "frmBuffIconPreview", container)
	preview:SetPoint("TOPLEFT", container, "TOPRIGHT", 25, 0)
	preview:SetWidth(200)
	preview:SetHeight(200)

	preview.config = GetConfiguration()

	preview.icon01 = data.ConstructIcon(preview, true)
	preview.icon02 = data.ConstructIcon(preview, true)
	preview.icon03 = data.ConstructIcon(preview, true)
	preview.icon04 = data.ConstructIcon(preview, true)

	UpdatePreview()

	colorBuffBorder.OnColorChanged = UpdatePreview 
	colorDebuffBorder.OnColorChanged = UpdatePreview 
	colorBuffText.OnColorChanged = UpdatePreview 
	colorDebuffText.OnColorChanged = UpdatePreview 
	colorBuffBackground.OnColorChanged = UpdatePreview 
	colorDebuffBackground.OnColorChanged = UpdatePreview 
	
	-- Priority Panel
	chkUsePriority = UI.CreateFrame("SimpleCheckbox", "chkUsePriority", frmPriority)
	sldMyBuffPriority = UI.CreateFrame("SimpleSlider", "sldMyBuffPriority", frmPriority)
	sldUnitBuffPriority = UI.CreateFrame("SimpleSlider", "sldUnitBuffPriority", frmPriority)
	sldOtherBuffPriority = UI.CreateFrame("SimpleSlider", "sldOtherBuffPriority", frmPriority)
	sldMyDebuffPriority = UI.CreateFrame("SimpleSlider", "sldMyDebuffPriority", frmPriority)
	sldUnitDebuffPriority = UI.CreateFrame("SimpleSlider", "sldUnitDebuffPriority", frmPriority)
	sldOtherDebuffPriority = UI.CreateFrame("SimpleSlider", "sldOtherDebuffPriority", frmPriority)
	labMyBuffPriority = UI.CreateFrame("Text", "labMyBuffPriority", frmPriority)
	labUnitBuffPriority = UI.CreateFrame("Text", "labUnitBuffPriority", frmPriority)
	labOtherBuffPriority = UI.CreateFrame("Text", "labOtherBuffPriority", frmPriority)
	labMyDebuffPriority = UI.CreateFrame("Text", "labMyDebuffPriority", frmPriority)
	labUnitDebuffPriority = UI.CreateFrame("Text", "labUnitDebuffPriority", frmPriority)
	labOtherDebuffPriority = UI.CreateFrame("Text", "labOtherDebuffPriority", frmPriority)
	
	chkUsePriority:SetText("Prioritise buffs by source")
	labMyBuffPriority:SetText("Buffs Cast by Player:")
	labUnitBuffPriority:SetText("Buffs Cast by Unit:")
	labOtherBuffPriority:SetText("Buffs Cast by Anyone Else:")
	labMyDebuffPriority:SetText("Debuffs Cast by Player:")
	labUnitDebuffPriority:SetText("Debuffs Cast by Unit:")
	labOtherDebuffPriority:SetText("Debuffs Cast by Anyone Else:")
	
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

local function OnPlayerAvailable()
end

if WT.VersionCheck("Gadgets", 0, 3, 78) then
	WT.Gadget.RegisterFactory("BuffIcons",
	{
		name="Buff Icons",
		description="Buff Icons Gadget",
		author="Wildtide",
		version="1.0.0",
		iconTexAddon = AddonId,
		iconTexFile = "img/wtBuffIcons.png",
		["Create"] = WT.Gadget.ConfigureBuffIcons,
		["Reconfigure"] = WT.Gadget.ConfigureBuffIcons,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})
end
