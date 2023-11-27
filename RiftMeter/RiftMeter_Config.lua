local Info, RM = ...

local L = RM.l
local VU = Library.VinceUtils

local tinsert = table.insert
local max = math.max
local min = math.min
local floor = math.floor
local round = function(val) return floor(val + .5) end

local TabControl = RM.TabControl
local ListBox = RM.ListBox
local Tooltip = RM.Tooltip
local Dialog = RM.Dialog
local Context = UI.CreateContext("RiftMeter_Config")
Context:SetStrata("notify")

local Config = {}
RM.Config = Config
function Config:init()
	-- Color animation
	self.animate = false
	self.lastAnimationUpdate = 0
	self.animationSpeed = 2 -- time in seconds to next color
	self.refreshRate = .1
	self.middleColor, self.rightColor = {RM.extractColors(math.random(0xffffff))}, {RM.extractColors(math.random(0xffffff))}

	local window = RM.createWindow("RM_Config", Context, self.hide)
	self.window = window
	window:SetVisible(false)
	window:SetAlpha(.95)
	window:SetWidth(620)
	window:SetHeight(420)
	window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", (UIParent:GetWidth() - window:GetWidth()) / 2, (UIParent:GetHeight() - window:GetHeight()) / 2)
	window:SetTitle(L["RiftMeter: Configuration"])
	window:SetLayer(0)

	local tabControl = TabControl:new("RM_Config_TabControl", window)
	tabControl:SetPoint("TOPLEFT", window, "TOPLEFT", 10, 5)
	tabControl:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -10, -25)

	local generalTab = UI.CreateFrame("Frame", "RM_Config_GeneralTab", window)
	local windowsTab = UI.CreateFrame("Frame", "RM_Config_WindowsTab", window)
	local colorsTab = UI.CreateFrame("Frame", "RM_Config_ColorsTab", window)

	local generalTab = tabControl:newTab(L["General"]).contentFrame
	local windowsTab = tabControl:newTab(L["Windows"]).contentFrame
	local colorsTab = tabControl:newTab(L["Colors"]).contentFrame


	-----------------------------------------
	-- General Tab
	-----------------------------------------
	self.lock = RM.createCheckboxWithLabel(
		"RM_Config_Lock", generalTab,
		"TOPLEFT", generalTab, "TOPLEFT", 10, 15,
		RiftMeter_lock, L["Lock Windows"], function()
			RiftMeter_lock = self.lock:GetChecked()
			RM.UI.ShowResizer(not RiftMeter_lock)
	end)

	self.alwaysShowPlayer = RM.createCheckboxWithLabel(
		"RM_Config_AlwaysShowPlayer", generalTab,
		"TOPLEFT", self.lock, "BOTTOMLEFT", 0, 4,
		RiftMeter_alwaysShowPlayer, L["Always show yourself"], function()
			RiftMeter_alwaysShowPlayer = self.alwaysShowPlayer:GetChecked()
			RM.UI.Update()
	end)

	self.showScrollbar = RM.createCheckboxWithLabel(
		"RM_Config_ShowScrollbar", generalTab,
		"TOPLEFT", self.alwaysShowPlayer, "BOTTOMLEFT", 0, 4,
		RiftMeter_showScrollbar, L["Show scrollbar"], function()
			RiftMeter_showScrollbar = self.showScrollbar:GetChecked()
			RM.UI.ShowScrollbar(RiftMeter_showScrollbar)
	end)

	self.mergeAbilitiesByName = RM.createCheckboxWithLabel(
		"RM_Config_MergeAbilitiesByName", generalTab,
		"TOPLEFT", self.showScrollbar, "BOTTOMLEFT", 0, 4,
		RiftMeter_mergeAbilitiesByName, L["Merge abilities by name"], function()
			RiftMeter_mergeAbilitiesByName = self.mergeAbilitiesByName:GetChecked()
			RM.UI.Update()
	end)

	self.showTooltips = RM.createCheckboxWithLabel(
		"RM_Config_showTooltips", generalTab,
		"TOPLEFT", self.mergeAbilitiesByName, "BOTTOMLEFT", 0, 4,
		RiftMeter_showTooltips, L["Show tooltips"], function()
			RiftMeter_showTooltips = self.showTooltips:GetChecked()
			RM.UI.Update()
	end)

	self.mergePets = RM.createCheckboxWithLabel(
		"RM_Config_MergePets", generalTab,
		"TOPLEFT", self.showTooltips, "BOTTOMLEFT", 0, 4,
		RiftMeter_mergePets, L["Merge pets"], function()
			for i, window in ipairs(RM.Windows) do
				window.scrollOffset = 0
			end
			RiftMeter_mergePets = self.mergePets:GetChecked()
			RM.UI.Update()
	end)

	self.absorbAsDamage = RM.createCheckboxWithLabel(
		"RM_Config_AbsorbAsDamage", generalTab,
		"TOPLEFT", self.mergePets, "BOTTOMLEFT", 0, 4,
		RiftMeter_absorbAsDamage, L["Absorb as damage"], function()
			RiftMeter_absorbAsDamage = self.absorbAsDamage:GetChecked()
			RM.UI.Update()
	end)




	self.showRankNumber = RM.createCheckboxWithLabel(
		"RM_Config_ShowRankNumber", generalTab,
		"BOTTOMLEFT", generalTab, "BOTTOMLEFT", 25, -45,
		RiftMeter_showRankNumber, L["Show rank number"], function()
			RiftMeter_showRankNumber = self.showRankNumber:GetChecked()
			RM.UI.Update()
	end)

	self.showAbsolute = RM.createCheckboxWithLabel(
		"RM_Config_ShowAbsolute", generalTab,
		"BOTTOMLEFT", self.showRankNumber, "TOPLEFT", 0, -4,
		RiftMeter_showAbsolute, L["Show absolute"], function()
			RiftMeter_showAbsolute = self.showAbsolute:GetChecked()
			RM.UI.Update()
	end)

	self.showPercent = RM.createCheckboxWithLabel(
		"RM_Config_ShowPercent", generalTab,
		"BOTTOMLEFT", self.showAbsolute, "TOPLEFT", 0, -4,
		RiftMeter_showPercent, L["Show percentage"], function()
			RiftMeter_showPercent = self.showPercent:GetChecked()
			RM.UI.Update()
	end)

	self.abbrNumbers = RM.createCheckboxWithLabel(
		"RM_Config_AbbrNumbers", generalTab,
		"BOTTOMLEFT", self.showPercent, "TOPLEFT", 0, -4,
		RiftMeter_abbreviateNumbers, L["Abbreviate numbers"], function()
			RiftMeter_abbreviateNumbers = self.abbrNumbers:GetChecked()
			RM.UI.Update()
	end)


	local barFormattingLabel = RM.createTextFrame("RM_Config_BarFormattingLabel", generalTab)
	barFormattingLabel:SetPoint("BOTTOMLEFT", self.abbrNumbers, "TOPLEFT", -15, -4)
	barFormattingLabel:SetText(L["Bar Formatting"] .. ":")
	barFormattingLabel:SetFontColor(1, .82, 0)
	barFormattingLabel:SetFontSize(13)



	local highlightYourselfLabel = RM.createTextFrame("RM_Config_HighlightYourselfLabel", generalTab)
	highlightYourselfLabel:SetPoint("TOPLEFT", barFormattingLabel, "TOPRIGHT", 100, 0)
	highlightYourselfLabel:SetText(L["Highlight Yourself"] .. ":")
	highlightYourselfLabel:SetFontColor(1, .82, 0)
	highlightYourselfLabel:SetFontSize(13)

	self.customHighlightFontColor = RM.createCheckboxWithLabel(
		"RM_Config_CustomHighlightFontColor", generalTab,
		"TOPLEFT", highlightYourselfLabel, "BOTTOMLEFT", 10, 4,
		RiftMeter_customHighlightFontColor, L["Custom font color"], function()
			RiftMeter_customHighlightFontColor = self.customHighlightFontColor:GetChecked()
			RM.UI.Update(true)
	end)

	self.customHighlightBackgroundColor = RM.createCheckboxWithLabel(
		"RM_Config_CustomHighlightBackgroundColor", generalTab,
		"TOPLEFT", self.customHighlightFontColor, "BOTTOMLEFT", 0, 4,
		RiftMeter_customHighlightBackgroundColor, L["Custom background color"], function()
			RiftMeter_customHighlightBackgroundColor = self.customHighlightBackgroundColor:GetChecked()
			RM.UI.Update(true)
	end)

	local customHightlightColorsLabel = RM.createTextFrame("RM_Config_HightlightColorsLabel", generalTab)
	customHightlightColorsLabel:SetPoint("TOPLEFT", self.customHighlightBackgroundColor, "BOTTOMLEFT", 0, 4)
	customHightlightColorsLabel:SetText(L["Set those values in colors tab"])
	customHightlightColorsLabel:SetFontColor(.75, .75, .75)



	local default = UI.CreateFrame("RiftButton", "RM_Config_Default", generalTab)
	default:SetPoint("TOPRIGHT", generalTab, "TOPRIGHT", -10, 15)
	default:SetText(L["Default"])
	default:EventAttach(Event.UI.Button.Left.Press, function()
		Dialog:show(L["Set to default?"], L["Yes"], L["No"], RM.Default, function() end)
	end, "Event.UI.Button.Left.Press")
	-----------------------------------------


	-----------------------------------------
	-- Windows Tab
	-----------------------------------------
	local addWindow = UI.CreateFrame("RiftButton", "RM_Config_AddWindow", windowsTab)
	local copyWindow = UI.CreateFrame("RiftButton", "RM_Config_CopyWindow", windowsTab)
	local removeWindow = UI.CreateFrame("RiftButton", "RM_Config_RemoveWindow", windowsTab)
	local windowsLabel = RM.createTextFrame("RM_Config_WindowsLabel", windowsTab)
	self.windowList = ListBox:new("RM_Config_WindowList", windowsTab)

	addWindow:SetPoint("TOPLEFT", windowsTab, "TOPLEFT", 10, 15)
	addWindow:SetText(L["Add"])
	addWindow:EventAttach(Event.UI.Button.Left.Press, function()
		RM.UI.NewWindow()
	end, "Event.UI.Button.Left.Press")

	copyWindow:SetPoint("TOPLEFT", addWindow, "BOTTOMLEFT")
	copyWindow:SetText(L["Copy"])
	copyWindow:EventAttach(Event.UI.Button.Left.Press, function()
		local settings = VU.deepcopy(RM.Windows[self.windowList:getSelectedIndex()].settings)
		settings.x = round((UIParent:GetWidth() - settings.width) / 2)
		settings.y = round(UIParent:GetHeight() / 2)
		RM.UI.NewWindow(settings)
	end, "Event.UI.Button.Left.Press")

	removeWindow:SetPoint("TOPLEFT", copyWindow, "BOTTOMLEFT")
	removeWindow:SetText(L["Remove"])
	removeWindow:EventAttach(Event.UI.Button.Left.Press, function()
		if #RM.Windows > 1 then
			RM.UI.CloseWindow(RM.Windows[self.windowList:getSelectedIndex()])
		end
	end, "Event.UI.Button.Left.Press")

	windowsLabel:SetPoint("TOPLEFT", removeWindow, "BOTTOMLEFT", 0, 15)
	windowsLabel:SetText(L["Windows"] .. ":")
	windowsLabel:SetFontColor(1, .82, 0)
	windowsLabel:SetFontSize(13)

	self.windowList:SetPoint("TOPLEFT", windowsLabel, "BOTTOMLEFT", 0, 5)
	self.windowList:SetPoint("RIGHT", removeWindow, "RIGHT")
	self.windowList:SetHeight(160) -- 8 * 20

	Command.Event.Attach(Event.RiftMeter.Window.TitleChange, function (handle, rmWindow, newTitle)
		for i, window in ipairs(RM.Windows) do
			if window == rmWindow then
				self.windowList:setLabel(i, newTitle)
				return
			end
		end
	end, "RM Window TitleChange")

	Command.Event.Attach(Event.RiftMeter.Window.Add, function (handle, rmWindow)
		self.windowList:addItem(rmWindow:getTitle())
	end, "RM Window Add")

	Command.Event.Attach(Event.RiftMeter.Window.Remove, function (handle, rmWindow)
		for i, window in ipairs(RM.Windows) do
			if window == rmWindow then
				self.windowList:removeItem(i)
				return
			end
		end
	end, "RM Window Remove")


	local windowTabControl = TabControl:new("RM_Config_WindowTabControl", windowsTab)
	windowTabControl:SetPoint("TOPLEFT", addWindow, "TOPRIGHT", 20, 0)
	windowTabControl:SetPoint("BOTTOMRIGHT", windowsTab, "BOTTOMRIGHT", -10, -25)

	local windowTab = UI.CreateFrame("Frame", "RM_Config_WindowTabControl_WindowTab", windowsTab)
	local titlebarTab = UI.CreateFrame("Frame", "RM_Config_WindowTabControl_TitleBarTab", windowsTab)
	local barsTab = UI.CreateFrame("Frame", "RM_Config_WindowTabControl_BarsTab", windowsTab)

	local windowTab = windowTabControl:newTab(L["Window"]).contentFrame
	local titlebarTab = windowTabControl:newTab(L["Title bar"]).contentFrame
	local barsTabTbl = windowTabControl:newTab(L["Bars"])
	local barsTab = barsTabTbl.contentFrame
	Tooltip.createForFrame(barsTabTbl.tabTexture, "700", barsTabTbl.tabTexture, true)
	-----------------------------------------


	-----------------------------------------
	-- Window Tab
	-----------------------------------------
	local windowBackgroundColor = RM.createColorPickerPreviewButton("RM_Config_WindowTab_BackgroundColor", windowTab, 0, 0, 0, 0, function (r, g, b, a)
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		selectedWindow.settings.backgroundColor[1] = r
		selectedWindow.settings.backgroundColor[2] = g
		selectedWindow.settings.backgroundColor[3] = b
		selectedWindow.settings.backgroundColor[4] = a
		selectedWindow:setBackgroundColor(r, g, b, a)
	end)
	windowBackgroundColor:SetPoint("TOPLEFT", windowTab, "TOPLEFT", 10, 15)

	local windowBackgroundColorLabel = RM.createTextFrame("RM_Config_WindowTab_BackgroundColor_Label", windowTab)
	windowBackgroundColorLabel:SetText(L["Background color"])
	windowBackgroundColorLabel:SetPoint("CENTERLEFT", windowBackgroundColor, "CENTERRIGHT", 6, 0)


	local footerBackgroundColor = RM.createColorPickerPreviewButton("RM_Config_WindowTab_FooterBackgroundColor", windowTab, 0, 0, 0, 0, function (r, g, b, a)
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		selectedWindow.settings.footerBackgroundColor[1] = r
		selectedWindow.settings.footerBackgroundColor[2] = g
		selectedWindow.settings.footerBackgroundColor[3] = b
		selectedWindow.settings.footerBackgroundColor[4] = a
		selectedWindow:setFooterBackgroundColor(r, g, b, a)
	end)
	footerBackgroundColor:SetPoint("TOPLEFT", windowBackgroundColor, "BOTTOMLEFT", 0, 10)

	local footerBackgroundColorLabel = RM.createTextFrame("RM_Config_WindowTab_FooterBackgroundColor_Label", windowTab)
	footerBackgroundColorLabel:SetText(L["Footer background color"])
	footerBackgroundColorLabel:SetPoint("CENTERLEFT", footerBackgroundColor, "CENTERRIGHT", 6, 0)
	-----------------------------------------


	-----------------------------------------
	-- Titlebar Tab
	-----------------------------------------
--	local enableTitlebar, enableTitlebarLabel = RM.createCheckboxWithLabel(
--		"RM_Config_enableTitlebar", titlebarTab,
--		"TOPLEFT", titlebarTab, "TOPLEFT", 10, 15,
--		true, L["Enable Titlebar"], function()
--			local window = RM.Windows[self.windowList:getSelectedIndex()]
--			window.settings.enableTitlebar.state = not window.settings.enableTitlebar.state
--			window:showTitlebar(window.settings.enableTitlebar.state)
--		end
--	)

	local titlebarColor = RM.createColorPickerPreviewButton("RM_Config_TitlebarTab_TitlebarColor", titlebarTab, 0, 0, 0, 0, function (r, g, b, a)
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		selectedWindow.settings.titlebarColor[1] = r
		selectedWindow.settings.titlebarColor[2] = g
		selectedWindow.settings.titlebarColor[3] = b
		selectedWindow.settings.titlebarColor[4] = a
		selectedWindow:setTitlebarAlpha(a)
	end)
	titlebarColor:SetPoint("TOPLEFT", titlebarTab, "TOPLEFT", 10, 15)

	local titlebarColorLabel = RM.createTextFrame("RM_Config_TitlebarTab_TitlebarColor_Label", titlebarTab)
	titlebarColorLabel:SetText(L["Background color"])
	titlebarColorLabel:SetPoint("CENTERLEFT", titlebarColor, "CENTERRIGHT", 6, 0)

	local titlebarColorNotice = RM.createTextFrame("RM_Config_TitlebarTab_TitlebarColor_Notice", titlebarTab)
	titlebarColorNotice:SetText(L["Only alpha works right now because there's no blend mode"])
	titlebarColorNotice:SetPoint("TOPLEFT", titlebarColorLabel, "BOTTOMLEFT", 0, -1)
	titlebarColorNotice:SetFontColor(.75, .75, .75)

	local titlebarFontColor = RM.createColorPickerPreviewButton("RM_Config_TitlebarTab_TitlebarFontColor", titlebarTab, 1, 1, 1, 1, function (r, g, b)
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		selectedWindow.settings.titlebarFontColor[1] = r
		selectedWindow.settings.titlebarFontColor[2] = g
		selectedWindow.settings.titlebarFontColor[3] = b
		selectedWindow:setTitlebarFontColor(r, g, b)
	end)
	titlebarFontColor:SetPoint("TOPLEFT", titlebarColor, "BOTTOMLEFT", 0, 20)

	local titlebarFontColorLabel = RM.createTextFrame("RM_Config_TitlebarTab_TitlebarFontColorLabel", titlebarTab)
	titlebarFontColorLabel:SetText(L["Font color"])
	titlebarFontColorLabel:SetPoint("CENTERLEFT", titlebarFontColor, "CENTERRIGHT", 6, 0)


	local titlebarHeightSlider = RM.createSlider("RM_Config_TitlebarTab_TitlebarHeight", titlebarTab, L["Height"], 8, 50, 8, function(position)
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		selectedWindow.settings.titlebarHeight = position
		selectedWindow:setTitlebarHeight(position)
	end)
	titlebarHeightSlider:SetPoint("TOPLEFT", titlebarFontColor, "BOTTOMLEFT", 0, 30)

	local titlebarFontSizeSlider = RM.createSlider("RM_Config_TitlebarTab_TitlebarFontSize", titlebarTab, L["Font size"], 7, 40, 7, function(position)
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		selectedWindow.settings.titlebarFontSize = position
		selectedWindow:setTitlebarFontSize(position)
	end)
	titlebarFontSizeSlider:SetPoint("TOPLEFT", titlebarHeightSlider, "TOPRIGHT", 10, 0)

--	local titlebarTexture = UI.CreateFrame("RiftTextfield", "RM_Config_TitlebarTab_TitlebarTexture", titlebarTab)
--	local titlebarTexturePreview = UI.CreateFrame("Texture", "RM_Config_TitlebarTab_TitlebarTexturePreview", titlebarTab)
--	titlebarTexturePreview:SetPoint("TOPLEFT", titlebarTexture, "BOTTOMLEFT", 0, 2)
--	titlebarTexture:SetPoint("TOPLEFT", titlebarHeightSlider, "TOPRIGHT", 30, 0)
--	titlebarTexture:SetBackgroundColor(0, 0, 0, .5)
--	titlebarTexture:SetWidth(titlebarTexture:GetWidth() / 2)
--	titlebarTexture.Event.TextfieldChange = function()
--		titlebarTexturePreview:SetTexture(Info.identifier, titlebarTexture:GetText())
--	end


	local buttonsLabel = RM.createTextFrame("RM_Config_TitlebarTab_ButtonsLabel", titlebarTab)
	buttonsLabel:SetPoint("TOPLEFT", titlebarHeightSlider, "BOTTOMLEFT", 0, 20)
	buttonsLabel:SetText(L["Buttons"] .. ":")
	buttonsLabel:SetFontColor(1, .82, 0)
	buttonsLabel:SetFontSize(13)

	-------- 1. row
	local combatStartPreviewButton = UI.CreateFrame("Texture", "RM_Config_TitlebarTab_CombatStartPreviewButton", titlebarTab)
	combatStartPreviewButton:SetTexture(Info.identifier, [[textures\icons-shadowless\control.png]])
	combatStartPreviewButton:SetPoint("TOPLEFT", buttonsLabel, "BOTTOMLEFT", 0, 6)
	local combatStartButtonCheckbox = RM.createCheckboxWithLabel("RM_Config_TitlebarTab_CombatStartCheckbox", titlebarTab, "TOPLEFT", combatStartPreviewButton, "TOPRIGHT", 4, 0, true, L["Force combat start"], function(state)
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		selectedWindow.settings.hideButtons.combatStart = not state
		selectedWindow:updateButtons()
	end)

	local showEnemiesPreviewButton = UI.CreateFrame("Texture", "RM_Config_TitlebarTab_ShowEnemiesPreviewButton", titlebarTab)
	showEnemiesPreviewButton:SetTexture(Info.identifier, [[textures\icons-shadowless\animal-monkey.png]])
	showEnemiesPreviewButton:SetPoint("TOPLEFT", combatStartPreviewButton, "TOPRIGHT", 160, 0)
	local showEnemiesButtonCheckbox = RM.createCheckboxWithLabel("RM_Config_TitlebarTab_ShowEnemiesCheckbox", titlebarTab, "TOPLEFT", showEnemiesPreviewButton, "TOPRIGHT", 4, 0, true, L["Show enemies"], function(state)
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		selectedWindow.settings.hideButtons.showEnemies = not state
		selectedWindow:updateButtons()
	end)
	-------- 2. row
	local configurationPreviewButton = UI.CreateFrame("Texture", "RM_Config_TitlebarTab_ConfigurationPreviewButton", titlebarTab)
	configurationPreviewButton:SetTexture(Info.identifier, [[textures\icons-shadowless\gear.png]])
	configurationPreviewButton:SetPoint("TOPLEFT", combatStartPreviewButton, "BOTTOMLEFT", 0, 6)
	local configurationButtonCheckbox = RM.createCheckboxWithLabel("RM_Config_TitlebarTab_ConfigurationCheckbox", titlebarTab, "TOPLEFT", configurationPreviewButton, "TOPRIGHT", 4, 0, true, L["Configuration"], function(state)
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		selectedWindow.settings.hideButtons.configuration = not state
		selectedWindow:updateButtons()
	end)

	local clearDataPreviewButton = UI.CreateFrame("Texture", "RM_Config_TitlebarTab_ClearDataPreviewButton", titlebarTab)
	clearDataPreviewButton:SetTexture(Info.identifier, [[textures\icons-shadowless\broom.png]])
	clearDataPreviewButton:SetPoint("TOPLEFT", configurationPreviewButton, "TOPRIGHT", 160, 0)
	local clearDataButtonCheckbox = RM.createCheckboxWithLabel("RM_Config_TitlebarTab_ClearDataCheckbox", titlebarTab, "TOPLEFT", clearDataPreviewButton, "TOPRIGHT", 4, 0, true, L["Clear data"], function(state)
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		selectedWindow.settings.hideButtons.clearData = not state
		selectedWindow:updateButtons()
	end)
	-------- 3. row
	local reportPreviewButton = UI.CreateFrame("Texture", "RM_Config_TitlebarTab_ReportPreviewButton", titlebarTab)
	reportPreviewButton:SetTexture(Info.identifier, [[textures\icons-shadowless\megaphone.png]])
	reportPreviewButton:SetPoint("TOPLEFT", configurationPreviewButton, "BOTTOMLEFT", 0, 6)
	local reportButtonCheckbox = RM.createCheckboxWithLabel("RM_Config_TitlebarTab_ReportCheckbox", titlebarTab, "TOPLEFT", reportPreviewButton, "TOPRIGHT", 4, 0, true, L["Report"], function(state)
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		selectedWindow.settings.hideButtons.report = not state
		selectedWindow:updateButtons()
	end)

	local closePreviewButton = UI.CreateFrame("Texture", "RM_Config_TitlebarTab_ClosePreviewButton", titlebarTab)
	closePreviewButton:SetTexture(Info.identifier, [[textures\icons-shadowless\cross.png]])
	closePreviewButton:SetPoint("TOPLEFT", reportPreviewButton, "TOPRIGHT", 160, 0)
	local closeButtonCheckbox = RM.createCheckboxWithLabel("RM_Config_TitlebarTab_CloseCheckbox", titlebarTab, "TOPLEFT", closePreviewButton, "TOPRIGHT", 4, 0, true, L["Close"], function(state)
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		selectedWindow.settings.hideButtons.close = not state
		selectedWindow:updateButtons()
	end)
	-----------------------------------------


	-----------------------------------------
	-- Bars Tab
	-----------------------------------------
	local rowHeightSlider = RM.createSlider("RM_Config_BarsTab_BarHeight", barsTab, L["Bar height"], 10, 40, 10, function(position)
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		selectedWindow.settings.rowHeight = position
		selectedWindow:setRowHeight(position)
	end)
	rowHeightSlider:SetPoint("TOPLEFT", barsTab, "TOPLEFT", 10, 30)

	local rowPaddingSlider = RM.createSlider("RM_Config_BarsTab_BarSpacing", barsTab, L["Bar spacing"], 0, 10, 0, function(position)
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		selectedWindow.settings.rowPadding = position
		selectedWindow:setRowPadding(position)
	end)
	rowPaddingSlider:SetPoint("TOPLEFT", rowHeightSlider, "TOPRIGHT", 10, 0)

	local rowFontSizeSlider = RM.createSlider("RM_Config_BarsTab_BarFontSize", barsTab, L["Bar font size"], 7, 40, 7, function(position)
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		selectedWindow.settings.rowFontSize = position
		selectedWindow:setRowFontSize(position)
	end)
	rowFontSizeSlider:SetPoint("TOPLEFT", rowHeightSlider, "BOTTOMLEFT", 0, 30)

	local rowFontColor = RM.createColorPickerPreviewButton("RM_Config_BarsTab_FontColor", barsTab, 1, 1, 1, 1, function (r, g, b)
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		selectedWindow.settings.rowFontColor[1] = r
		selectedWindow.settings.rowFontColor[2] = g
		selectedWindow.settings.rowFontColor[3] = b
		RM.UI.Update(true)
	end)
	rowFontColor:SetPoint("TOPLEFT", rowFontSizeSlider, "BOTTOMLEFT", 0, 20)

	local rowFontColorLabel = RM.createTextFrame("RM_Config_BarsTab_FontColorLabel", barsTab)
	rowFontColorLabel:SetText(L["Font color"])
	rowFontColorLabel:SetPoint("CENTERLEFT", rowFontColor, "CENTERRIGHT", 6, 0)

	local swapTextAndBarColor = RM.createCheckboxWithLabel("RM_Config_BarsTab_SwapTextAndBarColor", barsTab, "TOPLEFT", rowFontColor, "BOTTOMLEFT", 0, 15, true, L["Swap text and bar color"], function(state)
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		selectedWindow.settings.swapTextAndBarColor = state
		selectedWindow:update(true)
	end)
	-----------------------------------------

	self.windowList.beforeSelectionChange = Library.ColorPicker.hide
	self.windowList.selectionChange = function()
		local selectedWindow = RM.Windows[self.windowList:getSelectedIndex()]
		local settings = selectedWindow.settings

		windowBackgroundColor:SetBackgroundColor(unpack(settings.backgroundColor))
		footerBackgroundColor:SetBackgroundColor(unpack(settings.footerBackgroundColor))

		titlebarColor:SetBackgroundColor(unpack(settings.titlebarColor))
		titlebarFontColor:SetBackgroundColor(unpack(settings.titlebarFontColor))
		titlebarFontSizeSlider:SetPosition(settings.titlebarFontSize)
		titlebarHeightSlider:SetPosition(settings.titlebarHeight)

		combatStartButtonCheckbox:SetChecked(not settings.hideButtons.combatStart)
		showEnemiesButtonCheckbox:SetChecked(not settings.hideButtons.showEnemies)
		configurationButtonCheckbox:SetChecked(not settings.hideButtons.configuration)
		clearDataButtonCheckbox:SetChecked(not settings.hideButtons.clearData)
		reportButtonCheckbox:SetChecked(not settings.hideButtons.report)
		closeButtonCheckbox:SetChecked(not settings.hideButtons.close)

		rowHeightSlider:SetPosition(settings.rowHeight)
		rowPaddingSlider:SetPosition(settings.rowPadding)
		rowFontSizeSlider:SetPosition(settings.rowFontSize)
		rowFontColor:SetBackgroundColor(unpack(settings.rowFontColor))
		swapTextAndBarColor:SetChecked(settings.swapTextAndBarColor)
	end

	for i, rmWindow in ipairs(RM.Windows) do
		self.windowList:addItem(rmWindow:getTitle())
	end


	-----------------------------------------
	-- Colors Tab
	-----------------------------------------
	local classesLabel = RM.createTextFrame("RM_Config_ColorsTab_ClassesLabel", colorsTab)
	classesLabel:SetPoint("TOPLEFT", colorsTab, "TOPLEFT", 10, 15)
	classesLabel:SetText(L["Classes"] .. ":")
	classesLabel:SetFontColor(1, .82, 0)
	classesLabel:SetFontSize(13)

	self.clericColor = RM.createColorPickerPreviewButton("RM_Config_ColorsTab_ClericColor", colorsTab, RiftMeter_classColors.cleric[1], RiftMeter_classColors.cleric[2], RiftMeter_classColors.cleric[3], 1, function (r, g, b)
		RiftMeter_classColors.cleric[1] = r
		RiftMeter_classColors.cleric[2] = g
		RiftMeter_classColors.cleric[3] = b
		RM.UI.Update(true)
	end)
	self.clericColor:SetPoint("TOPLEFT", classesLabel, "BOTTOMLEFT", 5, 15)

	local clericColorLabel = RM.createTextFrame("RM_Config_ColorsTab_ClericColor_Label", colorsTab)
	clericColorLabel:SetText(L["Cleric"])
	clericColorLabel:SetPoint("CENTERLEFT", self.clericColor, "CENTERRIGHT", 6, 0)


	self.mageColor = RM.createColorPickerPreviewButton("RM_Config_ColorsTab_MageColor", colorsTab, RiftMeter_classColors.mage[1], RiftMeter_classColors.mage[2], RiftMeter_classColors.mage[3], 1, function (r, g, b)
		RiftMeter_classColors.mage[1] = r
		RiftMeter_classColors.mage[2] = g
		RiftMeter_classColors.mage[3] = b
		RM.UI.Update(true)
	end)
	self.mageColor:SetPoint("TOPLEFT", self.clericColor, "BOTTOMLEFT", 0, 10)

	local mageColorLabel = RM.createTextFrame("RM_Config_ColorsTab_MageColor_Label", colorsTab)
	mageColorLabel:SetText(L["Mage"])
	mageColorLabel:SetPoint("CENTERLEFT", self.mageColor, "CENTERRIGHT", 6, 0)


	self.primalistColor = RM.createColorPickerPreviewButton("RM_Config_ColorsTab_PrimalistColor", colorsTab, RiftMeter_classColors.primalist[1], RiftMeter_classColors.primalist[2], RiftMeter_classColors.primalist[3], 1, function (r, g, b)
		RiftMeter_classColors.primalist[1] = r
		RiftMeter_classColors.primalist[2] = g
		RiftMeter_classColors.primalist[3] = b
		RM.UI.Update(true)
	end)
	self.primalistColor:SetPoint("TOPLEFT", self.mageColor, "BOTTOMLEFT", 0, 10)

	local mageColorLabel = RM.createTextFrame("RM_Config_ColorsTab_PrimalistColor_Label", colorsTab)
	mageColorLabel:SetText(L["Primalist"])
	mageColorLabel:SetPoint("CENTERLEFT", self.primalistColor, "CENTERRIGHT", 6, 0)


	self.rogueColor = RM.createColorPickerPreviewButton("RM_Config_ColorsTab_RogueColor", colorsTab, RiftMeter_classColors.rogue[1], RiftMeter_classColors.rogue[2], RiftMeter_classColors.rogue[3], 1, function (r, g, b)
		RiftMeter_classColors.rogue[1] = r
		RiftMeter_classColors.rogue[2] = g
		RiftMeter_classColors.rogue[3] = b
		RM.UI.Update(true)
	end)
	self.rogueColor:SetPoint("TOPLEFT", self.primalistColor, "BOTTOMLEFT", 0, 10)

	local rogueColorLabel = RM.createTextFrame("RM_Config_ColorsTab_RogueColor_Label", colorsTab)
	rogueColorLabel:SetText(L["Rogue"])
	rogueColorLabel:SetPoint("CENTERLEFT", self.rogueColor, "CENTERRIGHT", 6, 0)


	self.warriorColor = RM.createColorPickerPreviewButton("RM_Config_ColorsTab_WarriorColor", colorsTab, RiftMeter_classColors.warrior[1], RiftMeter_classColors.warrior[2], RiftMeter_classColors.warrior[3], 1, function (r, g, b)
		RiftMeter_classColors.warrior[1] = r
		RiftMeter_classColors.warrior[2] = g
		RiftMeter_classColors.warrior[3] = b
		RM.UI.Update(true)
	end)
	self.warriorColor:SetPoint("TOPLEFT", self.rogueColor, "BOTTOMLEFT", 0, 10)

	local warriorColorLabel = RM.createTextFrame("RM_Config_ColorsTab_WarriorColor_Label", colorsTab)
	warriorColorLabel:SetText(L["Warrior"])
	warriorColorLabel:SetPoint("CENTERLEFT", self.warriorColor, "CENTERRIGHT", 6, 0)


	self.noneColor = RM.createColorPickerPreviewButton("RM_Config_ColorsTab_NoneColor", colorsTab, RiftMeter_classColors.none[1], RiftMeter_classColors.none[2], RiftMeter_classColors.none[3], 1, function (r, g, b)
		RiftMeter_classColors.none[1] = r
		RiftMeter_classColors.none[2] = g
		RiftMeter_classColors.none[3] = b
		RM.UI.Update(true)
	end)
	self.noneColor:SetPoint("TOPLEFT", self.warriorColor, "BOTTOMLEFT", 0, 10)

	local noneColorLabel = RM.createTextFrame("RM_Config_ColorsTab_NoneColor_Label", colorsTab)
	noneColorLabel:SetText(L["None"])
	noneColorLabel:SetPoint("CENTERLEFT", self.noneColor, "CENTERRIGHT", 6, 0)



	local abilitiesLabel = RM.createTextFrame("RM_Config_ColorsTab_AbilitiesLabel", colorsTab)
	abilitiesLabel:SetPoint("TOPLEFT", classesLabel, "TOPRIGHT", 100, 0)
	abilitiesLabel:SetText(L["Abilities"] .. ":")
	abilitiesLabel:SetFontColor(1, .82, 0)
	abilitiesLabel:SetFontSize(13)

	self.airColor = RM.createColorPickerPreviewButton("RM_Config_ColorsTab_AirColor", colorsTab, RiftMeter_abilityColors.air[1], RiftMeter_abilityColors.air[2], RiftMeter_abilityColors.air[3], 1, function (r, g, b)
		RiftMeter_abilityColors.air[1] = r
		RiftMeter_abilityColors.air[2] = g
		RiftMeter_abilityColors.air[3] = b
		RM.UI.Update(true)
	end)
	self.airColor:SetPoint("TOPLEFT", abilitiesLabel, "BOTTOMLEFT", 5, 15)

	local airColorLabel = RM.createTextFrame("RM_Config_ColorsTab_AirColor_Label", colorsTab)
	airColorLabel:SetText(L["Air"])
	airColorLabel:SetPoint("CENTERLEFT", self.airColor, "CENTERRIGHT", 6, 0)

	self.deathColor = RM.createColorPickerPreviewButton("RM_Config_ColorsTab_DeathColor", colorsTab, RiftMeter_abilityColors.death[1], RiftMeter_abilityColors.death[2], RiftMeter_abilityColors.death[3], 1, function (r, g, b)
		RiftMeter_abilityColors.death[1] = r
		RiftMeter_abilityColors.death[2] = g
		RiftMeter_abilityColors.death[3] = b
		RM.UI.Update(true)
	end)
	self.deathColor:SetPoint("TOPLEFT", self.airColor, "BOTTOMLEFT", 0, 10)

	local deathColorLabel = RM.createTextFrame("RM_Config_ColorsTab_DeathColor_Label", colorsTab)
	deathColorLabel:SetText(L["Death"])
	deathColorLabel:SetPoint("CENTERLEFT", self.deathColor, "CENTERRIGHT", 6, 0)

	self.earthColor = RM.createColorPickerPreviewButton("RM_Config_ColorsTab_EarthColor", colorsTab, RiftMeter_abilityColors.earth[1], RiftMeter_abilityColors.earth[2], RiftMeter_abilityColors.earth[3], 1, function (r, g, b)
		RiftMeter_abilityColors.earth[1] = r
		RiftMeter_abilityColors.earth[2] = g
		RiftMeter_abilityColors.earth[3] = b
		RM.UI.Update(true)
	end)
	self.earthColor:SetPoint("TOPLEFT", self.deathColor, "BOTTOMLEFT", 0, 10)

	local earthColorLabel = RM.createTextFrame("RM_Config_ColorsTab_EarthColor_Label", colorsTab)
	earthColorLabel:SetText(L["Earth"])
	earthColorLabel:SetPoint("CENTERLEFT", self.earthColor, "CENTERRIGHT", 6, 0)

	self.fireColor = RM.createColorPickerPreviewButton("RM_Config_ColorsTab_FireColor", colorsTab, RiftMeter_abilityColors.fire[1], RiftMeter_abilityColors.fire[2], RiftMeter_abilityColors.fire[3], 1, function (r, g, b)
		RiftMeter_abilityColors.fire[1] = r
		RiftMeter_abilityColors.fire[2] = g
		RiftMeter_abilityColors.fire[3] = b
		RM.UI.Update(true)
	end)
	self.fireColor:SetPoint("TOPLEFT", self.earthColor, "BOTTOMLEFT", 0, 10)

	local fireColorLabel = RM.createTextFrame("RM_Config_ColorsTab_FireColor_Label", colorsTab)
	fireColorLabel:SetText(L["Fire"])
	fireColorLabel:SetPoint("CENTERLEFT", self.fireColor, "CENTERRIGHT", 6, 0)

	self.lifeColor = RM.createColorPickerPreviewButton("RM_Config_ColorsTab_LifeColor", colorsTab, RiftMeter_abilityColors.life[1], RiftMeter_abilityColors.life[2], RiftMeter_abilityColors.life[3], 1, function (r, g, b)
		RiftMeter_abilityColors.life[1] = r
		RiftMeter_abilityColors.life[2] = g
		RiftMeter_abilityColors.life[3] = b
		RM.UI.Update(true)
	end)
	self.lifeColor:SetPoint("TOPLEFT", self.fireColor, "BOTTOMLEFT", 0, 10)

	local lifeColorLabel = RM.createTextFrame("RM_Config_ColorsTab_LifeColor_Label", colorsTab)
	lifeColorLabel:SetText(L["Life"])
	lifeColorLabel:SetPoint("CENTERLEFT", self.lifeColor, "CENTERRIGHT", 6, 0)

	self.waterColor = RM.createColorPickerPreviewButton("RM_Config_ColorsTab_WaterColor", colorsTab, RiftMeter_abilityColors.water[1], RiftMeter_abilityColors.water[2], RiftMeter_abilityColors.water[3], 1, function (r, g, b)
		RiftMeter_abilityColors.water[1] = r
		RiftMeter_abilityColors.water[2] = g
		RiftMeter_abilityColors.water[3] = b
		RM.UI.Update(true)
	end)
	self.waterColor:SetPoint("TOPLEFT", self.lifeColor, "BOTTOMLEFT", 0, 10)

	local waterColorLabel = RM.createTextFrame("RM_Config_ColorsTab_WaterColor_Label", colorsTab)
	waterColorLabel:SetText(L["Water"])
	waterColorLabel:SetPoint("CENTERLEFT", self.waterColor, "CENTERRIGHT", 6, 0)

	self.physicalColor = RM.createColorPickerPreviewButton("RM_Config_ColorsTab_PhysicalColor", colorsTab, RiftMeter_abilityColors.physical[1], RiftMeter_abilityColors.physical[2], RiftMeter_abilityColors.physical[3], 1, function (r, g, b)
		RiftMeter_abilityColors.physical[1] = r
		RiftMeter_abilityColors.physical[2] = g
		RiftMeter_abilityColors.physical[3] = b
		RM.UI.Update(true)
	end)
	self.physicalColor:SetPoint("TOPLEFT", self.waterColor, "BOTTOMLEFT", 0, 10)

	local physicalColorLabel = RM.createTextFrame("RM_Config_ColorsTab_PhysicalColor_Label", colorsTab)
	physicalColorLabel:SetText(L["Physical"])
	physicalColorLabel:SetPoint("CENTERLEFT", self.physicalColor, "CENTERRIGHT", 6, 0)





	local miscLabel = RM.createTextFrame("RM_Config_ColorsTab_MiscLabel", colorsTab)
	miscLabel:SetPoint("TOPLEFT", abilitiesLabel, "TOPRIGHT", 100, 0)
	miscLabel:SetText(L["Misc"] .. ":")
	miscLabel:SetFontColor(1, .82, 0)
	miscLabel:SetFontSize(13)

	self.totalbarColor = RM.createColorPickerPreviewButton("RM_Config_ColorsTab_TotalbarColor", colorsTab, RiftMeter_totalbarColor[1], RiftMeter_totalbarColor[2], RiftMeter_totalbarColor[3], 1, function (r, g, b)
		RiftMeter_totalbarColor[1] = r
		RiftMeter_totalbarColor[2] = g
		RiftMeter_totalbarColor[3] = b
		RM.UI.Update(true)
	end)
	self.totalbarColor:SetPoint("TOPLEFT", miscLabel, "BOTTOMLEFT", 5, 15)

	local totalbarColorLabel = RM.createTextFrame("RM_Config_ColorsTab_TotalbarColor_Label", colorsTab)
	totalbarColorLabel:SetText(L["Total bar"])
	totalbarColorLabel:SetPoint("CENTERLEFT", self.totalbarColor, "CENTERRIGHT", 6, 0)

	self.highlightFontColor = RM.createColorPickerPreviewButton("RM_Config_ColorsTab_HighlightFontColor", colorsTab, RiftMeter_customHighlightFontColorValue[1], RiftMeter_customHighlightFontColorValue[2], RiftMeter_customHighlightFontColorValue[3], 1, function (r, g, b)
		RiftMeter_customHighlightFontColorValue[1] = r
		RiftMeter_customHighlightFontColorValue[2] = g
		RiftMeter_customHighlightFontColorValue[3] = b
		RM.UI.Update(true)
	end)
	self.highlightFontColor:SetPoint("TOPLEFT", self.totalbarColor, "BOTTOMLEFT", 0, 10)

	local highlightFontColorLabel = RM.createTextFrame("RM_Config_ColorsTab_HighlightFontColor_Label", colorsTab)
	highlightFontColorLabel:SetText(L["Highlight font color"])
	highlightFontColorLabel:SetPoint("CENTERLEFT", self.highlightFontColor, "CENTERRIGHT", 6, 0)

	self.highlightBackgroundColor = RM.createColorPickerPreviewButton("RM_Config_ColorsTab_HighlightBackgroundColor", colorsTab, RiftMeter_customHighlightBackgroundColorValue[1], RiftMeter_customHighlightBackgroundColorValue[2], RiftMeter_customHighlightBackgroundColorValue[3], 1, function (r, g, b)
		RiftMeter_customHighlightBackgroundColorValue[1] = r
		RiftMeter_customHighlightBackgroundColorValue[2] = g
		RiftMeter_customHighlightBackgroundColorValue[3] = b
		RM.UI.Update(true)
	end)
	self.highlightBackgroundColor:SetPoint("TOPLEFT", self.highlightFontColor, "BOTTOMLEFT", 0, 10)

	local highlightBackgroundColorLabel = RM.createTextFrame("RM_Config_ColorsTab_HighlightFontColor_Label", colorsTab)
	highlightBackgroundColorLabel:SetText(L["Highlight background color"])
	highlightBackgroundColorLabel:SetPoint("CENTERLEFT", self.highlightBackgroundColor, "CENTERRIGHT", 6, 0)



	self.infoText = ("%s v%s - %s"):format(Info.toc.Name, Info.toc.Version, Info.toc.Author)
	self.info = RM.createTextFrame("RM_Config_Info", window)
	self.info:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -10, -5)
	self.info:SetText(self.infoText)
	self.info:EventAttach(Event.UI.Input.Mouse.Left.Click, function()
		self.animate = not self.animate
		if self.animate then
			self.lastAnimationUpdate = Inspect.Time.Frame() - self.refreshRate
			self:animationKeyFrame()
			Command.Event.Attach(Event.System.Update.Begin, self.animation, "Animation")
		else
			Command.Event.Detach(Event.System.Update.Begin, self.animation)
		end
	end, "Event.UI.Input.Mouse.Left.Click")
end
function Config:show()
	if not self.window then
		self:init()
	end

	self:update()

	if self.animate then
		self.lastAnimationUpdate = Inspect.Time.Frame()
		Command.Event.Attach(Event.System.Update.Begin, self.animation, "Animation")
	end
	self.window:SetVisible(true)
end
function Config:hide()
	local self = Config
	self.window:SetVisible(false)

	Library.ColorPicker:hide()

	Command.Event.Detach(Event.System.Update.Begin, self.animation)
end
function Config:toggle()
	if not self.window or not self.window:GetVisible() then
		self:show()
	else
		self:hide()
	end
end
function Config:update()
	if not self.window or not self.window:GetVisible() then
		return
	end

	self.lock:SetChecked(RiftMeter_lock)
	self.alwaysShowPlayer:SetChecked(RiftMeter_alwaysShowPlayer)
	self.showScrollbar:SetChecked(RiftMeter_showScrollbar)
	self.mergeAbilitiesByName:SetChecked(RiftMeter_mergeAbilitiesByName)
	self.showTooltips:SetChecked(RiftMeter_showTooltips)
	self.mergePets:SetChecked(RiftMeter_mergePets)
	self.absorbAsDamage:SetChecked(RiftMeter_absorbAsDamage)

	self.showRankNumber:SetChecked(RiftMeter_showRankNumber)
	self.showAbsolute:SetChecked(RiftMeter_showAbsolute)
	self.showPercent:SetChecked(RiftMeter_showPercent)

	self.customHighlightFontColor:SetChecked(RiftMeter_customHighlightFontColor)
	self.customHighlightBackgroundColor:SetChecked(RiftMeter_customHighlightBackgroundColor)

	self.clericColor:SetBackgroundColor(unpack(RiftMeter_classColors.cleric))
	self.mageColor:SetBackgroundColor(unpack(RiftMeter_classColors.mage))
	self.rogueColor:SetBackgroundColor(unpack(RiftMeter_classColors.rogue))
	self.warriorColor:SetBackgroundColor(unpack(RiftMeter_classColors.warrior))
	self.noneColor:SetBackgroundColor(unpack(RiftMeter_classColors.none))

	self.airColor:SetBackgroundColor(unpack(RiftMeter_abilityColors.air))
	self.deathColor:SetBackgroundColor(unpack(RiftMeter_abilityColors.death))
	self.earthColor:SetBackgroundColor(unpack(RiftMeter_abilityColors.earth))
	self.fireColor:SetBackgroundColor(unpack(RiftMeter_abilityColors.fire))
	self.lifeColor:SetBackgroundColor(unpack(RiftMeter_abilityColors.life))
	self.waterColor:SetBackgroundColor(unpack(RiftMeter_abilityColors.water))
	self.physicalColor:SetBackgroundColor(unpack(RiftMeter_abilityColors.physical))

	self.totalbarColor:SetBackgroundColor(unpack(RiftMeter_totalbarColor))
	self.highlightFontColor:SetBackgroundColor(unpack(RiftMeter_customHighlightFontColorValue))
	self.highlightBackgroundColor:SetBackgroundColor(unpack(RiftMeter_customHighlightBackgroundColorValue))

	self.windowList.selectionChange()
end
function Config.animation()
	local self = Config
	local now = Inspect.Time.Frame()
	local diff = now - self.lastAnimationUpdate
	local rate = diff / self.refreshRate

	if diff >= self.refreshRate then
		self.lastAnimationUpdate = now
		self.animationIndex = self.animationIndex + 1 * rate

		self.middleColor[1] = max(min(self.middleColor[1] + self.stepMiddle.r * rate, 255), 0)
		self.middleColor[2] = max(min(self.middleColor[2] + self.stepMiddle.g * rate, 255), 0)
		self.middleColor[3] = max(min(self.middleColor[3] + self.stepMiddle.b * rate, 255), 0)

		self.rightColor[1] = max(min(self.rightColor[1] + self.stepRight.r * rate, 255), 0)
		self.rightColor[2] = max(min(self.rightColor[2] + self.stepRight.g * rate, 255), 0)
		self.rightColor[3] = max(min(self.rightColor[3] + self.stepRight.b * rate, 255), 0)

		self.info:SetText(RM.colorize(self.infoText, RM.toColor(self.middleColor), RM.toColor(self.rightColor)), true)

		if self.animationIndex >= self.animationSpeed / self.refreshRate then
			self:animationKeyFrame()
		end
	end
end
function Config:animationKeyFrame()
	self.animationIndex = 0
	self.leftColor = {RM.extractColors(math.random(0xffffff)) }

	self.stepMiddle = {
		r = (self.leftColor[1] - self.middleColor[1]) / (self.animationSpeed / self.refreshRate),
		g = (self.leftColor[2] - self.middleColor[2]) / (self.animationSpeed / self.refreshRate),
		b = (self.leftColor[3] - self.middleColor[3]) / (self.animationSpeed / self.refreshRate)
	}

	self.stepRight = {
		r = (self.middleColor[1] - self.rightColor[1]) / (self.animationSpeed / self.refreshRate),
		g = (self.middleColor[2] - self.rightColor[2]) / (self.animationSpeed / self.refreshRate),
		b = (self.middleColor[3] - self.rightColor[3]) / (self.animationSpeed / self.refreshRate)
	}
end
